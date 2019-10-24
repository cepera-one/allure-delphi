unit allureFileSystemResultsWriter;

interface

uses
  System.SysUtils, Winapi.Windows, allureDelphiInterface, allureCommon,
  System.Classes, allureDelphiHelper, allureModel, System.JSON.Builders,
  System.JSON.Types, System.JSON.Writers, System.IOUtils;

type

  TAllureFileSystemResultsWriter = class(TAllureInterfacedObject, IAllureResultsWriter)
  private
    fOutputDirectory: string;
    fConfig: IAllureConfiguration;
    procedure WriteExecutableItem(EItem: TAllureExecutableItem; jso: TJSONCollectionBuilder.TPairs);
    procedure WriteLinks(Links: TAllureLinkList; jso: TJSONCollectionBuilder.TPairs);
    procedure WriteLabels(Labels: TAllureLabels; jso: TJSONCollectionBuilder.TPairs);
  public
    constructor Create(const Config: IAllureConfiguration; ASelfIncrement: Boolean = false);
    destructor Destroy; override;

    (*
     * Writes Allure test result bean.
     *
     * @param testResult the given bean to write.
     * @throws AllureResultsWriteException if some error occurs
     *                                     during operation.
     *)
    procedure WriteTest(TestResult: TAllureTestResult);

    (*
     * Writes Allure test result container bean.
     *
     * @param testResultContainer the given bean to write.
     * @throws AllureResultsWriteException if some error occurs
     *                                     during operation.
     *)
    procedure WriteTestContainer(TestResultContainer: TAllureTestResultContainer);

    (*
     * Writes given attachment. Will close the given stream.
     *
     * @param source     the file name of the attachment. Make sure that file name
     *                   matches the following glob: <pre>*-attachment*</pre>. The right way
     *                   to generate attachment is generate UUID, determinate attachment
     *                   extension and then use it as <pre>{UUID}-attachment.{ext}</pre>
     * @param attachment the steam that contains attachment body.
     *)
    procedure WriteAttachment(const Source: String; Attachment: TStream);
  end;

implementation

{ TAllureFileSystemResultsWriter }

constructor TAllureFileSystemResultsWriter.Create(
  const Config: IAllureConfiguration; ASelfIncrement: Boolean = false);
begin
  inherited Create;
  fConfig := Config;
  fOutputDirectory := Config.Directory;
  SelfIncrement := ASelfIncrement;
end;

destructor TAllureFileSystemResultsWriter.Destroy;
begin
  inherited;
end;

procedure TAllureFileSystemResultsWriter.WriteAttachment(const Source: String;
  Attachment: TStream);
var
  fn: string;
  fs: TFileStream;
begin
  if (Source='') or (Attachment=nil) then exit;
  try
    ForceDirectories(fOutputDirectory);
    fn := fOutputDirectory + '\' + Source;
    fs := TFileStream.Create(fn, fmCreate);
    try
      fs.CopyFrom(Attachment, Attachment.Size);
    finally
      fs.Free;
    end;
  except
  end;
end;

procedure TAllureFileSystemResultsWriter.WriteExecutableItem(
  EItem: TAllureExecutableItem; jso: TJSONCollectionBuilder.TPairs);
var
  obj: TJSONCollectionBuilder.TPairs;
  ar: TJSONCollectionBuilder.TElements;
  i: Integer;
begin
  if (EItem=nil) or (jso=nil) then exit;
  if EItem.Name<>'' then
    jso.Add('name', EItem.Name);
  if EItem.Description<>'' then
    jso.Add('description', EItem.Description);
  if EItem.DescriptionHtml<>'' then
    jso.Add('descriptionHtml', EItem.DescriptionHtml);
  jso.Add('status', EItem.Status.ToString);
  if EItem.StatusDetailsAssigned then begin
    obj := jso.BeginObject('statusDetails');
    try
      obj.Add('known', EItem.StatusDetails.Known);
      obj.Add('muted', EItem.StatusDetails.Muted);
      obj.Add('flaky', EItem.StatusDetails.Flaky);
      obj.Add('message', EItem.StatusDetails.Message);
      obj.Add('trace', EItem.StatusDetails.Trace);
    finally
      obj.EndObject;
    end;
  end;
  jso.Add('stage', EItem.Stage.ToString);
  jso.Add('start', EItem.Start.ToString);
  jso.Add('stop', EItem.Stop.ToString);
  ar := jso.BeginArray('attachments');
  try
    for i := 0 to EItem.Attachments.AttachmentCount-1 do begin
      obj := ar.BeginObject;
      try
        obj.Add('name', EItem.Attachments.Attachment[i].Name);
        obj.Add('source', EItem.Attachments.Attachment[i].Source);
        obj.Add('type', EItem.Attachments.Attachment[i].AttachmentType);
      finally
        obj.EndObject;
      end;
    end;
  finally
    ar.EndArray;
  end;
  ar := jso.BeginArray('parameters');
  try
    for i := 0 to EItem.Parameters.ParameterCount-1 do begin
      obj := ar.BeginObject;
      try
        obj.Add('name', EItem.Parameters.Parameter[i].Name);
        obj.Add('value', EItem.Parameters.Parameter[i].Value);
      finally
        obj.EndObject;
      end;
    end;
  finally
    ar.EndArray;
  end;
  if EItem.StepsAssigned then begin
    ar := jso.BeginArray('steps');
    try
      for i := 0 to EItem.Steps.StepCount-1 do begin
        obj := ar.BeginObject;
        try
          WriteExecutableItem(TAllureInterfacedObject.ToClass<TAllureExecutableItem>(EItem.Steps.Step[i]), obj);
        finally
          obj.EndObject;
        end;
      end;
    finally
      ar.EndArray;
    end;
  end;
end;

procedure TAllureFileSystemResultsWriter.WriteLabels(Labels: TAllureLabels;
  jso: TJSONCollectionBuilder.TPairs);
var
  obj: TJSONCollectionBuilder.TPairs;
  ar: TJSONCollectionBuilder.TElements;
  i: Integer;
begin
  if (Labels=nil) or (jso=nil) then exit;
  ar := jso.BeginArray('labels');
  try
    for i := 0 to Labels.LabelCount-1 do begin
      obj := ar.BeginObject;
      try
        obj.Add('name', Labels.Labels[i].Name);
        obj.Add('value', Labels.Labels[i].Value);
      finally
        obj.EndObject;
      end;
    end;
  finally
    ar.EndArray;
  end;
end;

procedure TAllureFileSystemResultsWriter.WriteLinks(Links: TAllureLinkList;
  jso: TJSONCollectionBuilder.TPairs);
var
  obj: TJSONCollectionBuilder.TPairs;
  ar: TJSONCollectionBuilder.TElements;
  i: Integer;
begin
  if (Links=nil) or (jso=nil) then exit;
  ar := jso.BeginArray('links');
  try
    for i := 0 to Links.LinkCount-1 do begin
      obj := ar.BeginObject;
      try
        obj.Add('name', Links.Link[i].Name);
        obj.Add('url', Links.Link[i].Url);
        obj.Add('type', Links.Link[i].LinkType);
      finally
        obj.EndObject;
      end;
    end;
  finally
    ar.EndArray;
  end;
end;

procedure TAllureFileSystemResultsWriter.WriteTest(
  TestResult: TAllureTestResult);
var
  Builder: TJSONObjectBuilder;
  Writer: TJsonTextWriter;
  StreamWriter: TStreamWriter;
  fn: string;
  tob: TJSONCollectionBuilder.TPairs;
begin
  if TestResult=nil then exit;
  TAllureLinkHelper.UpdateLinks(TestResult.Links, fConfig.Links);
  ForceDirectories(fOutputDirectory);
  fn := fOutputDirectory + '\' + TestResult.UUID + TEST_RESULT_FILE_SUFFIX;
  StreamWriter := TStreamWriter.Create(fn);
  Writer := TJsonTextWriter.Create(StreamWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    tob := Builder.BeginObject;
    try
      tob.Add('uuid', TestResult.UUID);
      if TestResult.HistoryID<>'' then
        tob.Add('historyId', TestResult.HistoryID);
      if TestResult.FullName<>'' then
        tob.Add('fullName', TestResult.FullName);
      if TestResult.TestCaseID<>'' then
        tob.Add('testCaseID', TestResult.TestCaseID);
      if TestResult.ReturnOf<>'' then
        tob.Add('returnOf', TestResult.ReturnOf);

      WriteExecutableItem(TestResult, tob);

      if TestResult.LinksAssigned then
        WriteLinks(TAllureInterfacedObject.ToClass<TAllureLinkList>(TestResult.Links), tob);
      if TestResult.LabelsAssigned then
        WriteLabels(TAllureInterfacedObject.ToClass<TAllureLabels>(TestResult.Labels), tob);
    finally
      tob.EndObject;
    end;
  finally
    FreeAndNil(Builder);
    FreeAndNil(Writer);
    FreeAndNil(StreamWriter);
  end;
end;

procedure TAllureFileSystemResultsWriter.WriteTestContainer(
  TestResultContainer: TAllureTestResultContainer);
var
  Builder: TJSONObjectBuilder;
  Writer: TJsonTextWriter;
  StreamWriter: TStreamWriter;
  fn: string;
  tob, jso: TJSONCollectionBuilder.TPairs;
  ar: TJSONCollectionBuilder.TElements;
  i: Integer;
begin
  if TestResultContainer=nil then exit;
  TAllureLinkHelper.UpdateLinks(TestResultContainer.Links, fConfig.Links);
  ForceDirectories(fOutputDirectory);
  fn := fOutputDirectory + '\' + TestResultContainer.UUID + TEST_RESULT_CONTAINER_FILE_SUFFIX;
  StreamWriter := TStreamWriter.Create(fn);
  Writer := TJsonTextWriter.Create(StreamWriter);
  Writer.Formatting := TJsonFormatting.Indented;
  Builder := TJSONObjectBuilder.Create(Writer);
  try
    tob := Builder.BeginObject;
    try
      tob.Add('uuid', TestResultContainer.UUID);
      tob.Add('name', TestResultContainer.Name);
      if TestResultContainer.Description<>'' then
        tob.Add('description', TestResultContainer.Description);
      if TestResultContainer.DescriptionHtml<>'' then
        tob.Add('descriptionHtml', TestResultContainer.DescriptionHtml);
      tob.Add('start', TestResultContainer.Start.ToString);
      tob.Add('stop', TestResultContainer.Stop.ToString);
      if TestResultContainer.LinksAssigned then
        WriteLinks(TAllureInterfacedObject.ToClass<TAllureLinkList>(TestResultContainer.Links), tob);
      ar := tob.BeginArray('children');
      try
        for i := 0 to TestResultContainer.Children.Count-1 do begin
          ar.Add(TestResultContainer.Children.Value[i]);
        end;
      finally
        ar.EndArray;
      end;
      if TestResultContainer.BeforesAssigned then begin
        ar := tob.BeginArray('befores');
        try
          for i := 0 to TestResultContainer.Befores.FixtureResultCount-1 do begin
            jso := ar.BeginObject;
            try
              WriteExecutableItem(
                TAllureInterfacedObject.ToClass<TAllureExecutableItem>(
                  TestResultContainer.Befores.FixtureResult[i]
                ), jso);
            finally
              jso.EndObject;
            end;
          end;
        finally
          ar.EndArray;
        end;
      end;
      if TestResultContainer.AftersAssigned then begin
        ar := tob.BeginArray('afters');
        try
          for i := 0 to TestResultContainer.Afters.FixtureResultCount-1 do begin
            jso := ar.BeginObject;
            try
              WriteExecutableItem(
                TAllureInterfacedObject.ToClass<TAllureExecutableItem>(
                  TestResultContainer.Afters.FixtureResult[i]
                ), jso);
            finally
              jso.EndObject;
            end;
          end;
        finally
          ar.EndArray;
        end;
      end;
    finally
      tob.EndObject;
    end;
  finally
    FreeAndNil(Builder);
    FreeAndNil(Writer);
    FreeAndNil(StreamWriter);
  end;
end;

end.
