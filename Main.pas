unit Main;

interface

uses
    Windows, SysUtils, Classes, Graphics, Controls, Forms, Grids,
    ExtCtrls, ComCtrls, StdCtrls, Contnrs;

type
    ECollission = class(Exception)
        constructor Create;
    end;

    TDirection = (sdUp, sdDown, sdLeft, sdRight);
    TSnakeDataType = (dtHead, dtBody, dtTail);
    TGridValue = (gvEmpty, gvWall, gvFood, gvBug, gvSnake1, gvSnake2);

    TSnakeImage = (
        imHEAD_UP, imHEAD_DOWN, imHEAD_LEFT, imHEAD_RIGHT, imTAIL_UP,
        imTAIL_DOWN, imTAIL_LEFT, imTAIL_RIGHT,
        imBODY_HORZ, imBODY_VERT, imBODY_UL, imBODY_DL, imBODY_UR, imBODY_DR, imFOOD, imBUG);

    TSnakeGridCoord = record
        Row, Col: Integer;
    end;

    TSnakeData = record
        Row, Col: Integer;
        DataType: TSnakeDataType;
        Direction: TDirection;
    end;

    TSnakeBody = array of TSnakeData;

    TSnake = class;

    TGridContents = record
        GridValue: TGridValue;
        Snake: TSnake;
        BodyIndex: Integer;
    end;

    TSnake = class
    private
        FLength: Integer;
        FBody: TSnakeBody;
        FLastDirection,
            FDirection: TDirection;
        FScore: Integer;
        FNo: Integer;
        procedure SetLength(const Value: Integer);
        procedure SetDirection(const Value: TDirection);
    protected
        procedure AddBody;
        function GetImageIndex(Position: Integer): TSnakeImage;
        function Head: TSnakeData;
        procedure Move;
        procedure MoveBody(NewPoint: TSnakeData);
        procedure TestForCollision(AHead: TSnakeData);
    public
        constructor Create(
            ANo: Integer; StartingPoint:
            TSnakeData;
            iInitialLength: Integer;
            ADirection: TDirection
        );
        property Score: Integer read FScore write FScore;
        property Length: Integer read FLength write SetLength;
        property Body: TSnakeBody read FBody;
        property Direction: TDirection read FDirection write SetDirection;
        property No: Integer read FNo write FNo;
    end;

    TfrmSnakeMain = class(TForm)
        Grid: TDrawGrid;
        gbPlayer1: TGroupBox;
        lbScoreP1: TLabel;
        lbPlayer1: TLabel;
        gbPlayer2: TGroupBox;
        lbHiScoreP1: TLabel;
        lbHiScore: TLabel;
        btnStart: TButton;
        tmrInterrupt: TTimer;
        lbBugIndicator: TLabel;
        lbLevelText: TLabel;
        tmrBug: TTimer;
        tbLevel: TTrackBar;
        procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
        procedure FormCreate(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure tmrInterruptTimer(Sender: TObject);
        procedure btnStartClick(Sender: TObject);
        procedure tbLevelChange(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure tmrBugTimer(Sender: TObject);
    private
        FResourceImages: TObjectList;
        FKeyList: TList;
        GridData: array of array of TGridContents;
        snkPlayer1 {, snkPlayer2}: TSnake;
        FStop: Boolean;
        FBug, FFood: TSnakeGridCoord;
        FFoodEaten, FBugCountDown: Integer;
        FHiScore: Integer;
        procedure LoadAllResources;
        procedure CheckKeys;
        procedure DoBuildGridData;
        procedure EmptyGridData;
        procedure doWalls;
        procedure doDrawSnake(ASnake: TSnake; AShowing: Boolean = True);
        function GetEmptyPoint: TSnakeGridCoord;
        procedure doGetFood;
        procedure doGetBug;
        procedure doFoodEaten(ASnake: TSnake);
        procedure doBugEaten(ASnake: TSnake);
        procedure UpdateScore(ALabel: TLabel; Value: Integer);
        procedure SetHiScore(const Value: Integer);
        function LoadHiScore: Integer;
        procedure SaveHiScore(const Value: Integer);
    public
        procedure GameOver;
        procedure doInitialise;
        property HiScore: Integer read FHiScore write SetHiScore;
    end;

var
    frmSnakeMain    : TfrmSnakeMain;

const
    cLEVELS         = 7;
    cSPEED          : array[1..cLEVELS] of Integer = (80, 100, 150, 200, 250, 350, 500);
    cGRID_COLORS    : array[TGridValue] of TColor = (clWindow, $0000329D, clRed, clMaroon, 0, 0);
    cSNAKE_COLOR    : array[1..2, TSnakeDataType] of TColor = (($00254529, $0045814D, $005CA766), (clGreen, clLime, clAqua));
    cSNAKE_LENGTH   = 8;
    cBUG_LIFE       = 15;
    cBUG_SCORE      = 5;
    cGAME_OVER      = 'GAME OVER';
    cSNAKE1_START   : TSnakeData = (Row: 5; Col: 5; DataType: dtBody);
    cV_DIRECTIONS   = [sdUp, sdDown];
    cH_DIRECTIONS   = [sdLeft, sdRight];
    cRESOURCE_NAME  : array[TSnakeImage] of string = ('HEAD_UP', 'HEAD_DOWN', 'HEAD_LEFT', 'HEAD_RIGHT',
        'TAIL_UP', 'TAIL_DOWN', 'TAIL_LEFT', 'TAIL_RIGHT',
        'BODY_HORZ', 'BODY_VERT', 'BODY_UL', 'BODY_DL', 'BODY_UR', 'BODY_DR', 'FOOD', 'BUG');
    cREG_KEY        = 'SOFTWARE\LaanSnake';
    cSCORE_VALUE    = 'HiScore';

implementation

uses Registry, Math;

{$R *.DFM}
{$R SnakeImages.RES}

{ ECollission }

constructor ECollission.Create;
begin
    frmSnakeMain.GameOver;
    Abort;
end;

{ TfrmSnakeMain }

procedure TfrmSnakeMain.FormCreate(Sender: TObject);
begin
    LoadAllResources;
    FKeyList := TList.Create;
    UpdateScore(lbHiScoreP1, LoadHiScore);
    tbLevel.Max := cLEVELS;
    Grid.DoubleBuffered := True;
    Randomize;
    FormResize(Self);
    DoBuildGridData;
    EmptyGridData;
end;

procedure TfrmSnakeMain.FormShow(Sender: TObject);
begin
    doInitialise;
end;

procedure TfrmSnakeMain.doInitialise;
begin
    FStop := False;
    FFoodEaten := 0;
    FBugCountDown := 0;
    tmrBug.Enabled := False;
    EmptyGridData;
    doWalls;
    Grid.Invalidate;
end;

procedure TfrmSnakeMain.doWalls;
var
    x               : Integer;
begin
    for x := 6 to Grid.ColCount - 5 do
        GridData[4, x].GridValue := gvWall;

    for x := 6 to Grid.ColCount - 5 do
        GridData[Grid.RowCount - 3, x].GridValue := gvWall;

    GridData[1, 1].GridValue := gvWall;
    GridData[1, 2].GridValue := gvWall;
    GridData[2, 1].GridValue := gvWall;
    GridData[1, Grid.ColCount].GridValue := gvWall;
    GridData[1, Grid.ColCount - 1].GridValue := gvWall;
    GridData[2, Grid.ColCount].GridValue := gvWall;
    GridData[Grid.RowCount, 1].GridValue := gvWall;
    GridData[Grid.RowCount - 1, 1].GridValue := gvWall;
    GridData[Grid.RowCount, 2].GridValue := gvWall;
    GridData[Grid.RowCount, Grid.ColCount].GridValue := gvWall;
    GridData[Grid.RowCount, Grid.ColCount - 1].GridValue := gvWall;
    GridData[Grid.RowCount - 1, Grid.ColCount].GridValue := gvWall;
end;

procedure TfrmSnakeMain.doBuildGridData;
var
    x, y            : Integer;
begin
    SetLength(GridData, Grid.RowCount + 1);
    for x := Low(GridData) to High(GridData) do
    begin
        SetLength(GridData[x], Grid.ColCount + 1);
        for y := Low(GridData[x]) to High(GridData[x]) do
        begin
            GridData[x, y].GridValue := gvEmpty;
            GridData[x, y].Snake := nil;
        end;
    end;
    GridData[FFood.Row, FFood.Col].GridValue := gvFood;
    if tmrBug.Enabled then
        GridData[FBug.Row, FBug.Col].GridValue := gvBug;
    DoWalls;
end;

procedure TfrmSnakeMain.doDrawSnake(ASnake: TSnake; AShowing: Boolean = True);
var
    iLength         : Integer;
    APoint          : TSnakeData;
begin
    if Assigned(ASnake) then
        for iLength := 0 to ASnake.Length - 1 do
        begin
            APoint := ASnake.Body[iLength];
            GridData[APoint.Row, APoint.Col].Snake := ASnake;
            GridData[APoint.Row, APoint.Col].BodyIndex := iLength;
            if AShowing then
                GridData[APoint.Row, APoint.Col].GridValue := TGridValue(ASnake.No + Ord(gvSnake1) - 1) // ie gvSnake1 or gvSnake2
            else
                GridData[APoint.Row, APoint.Col].GridValue := gvEmpty;
        end;
    OnKeyDown := FormKeyDown;
end;

procedure TfrmSnakeMain.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);

    procedure DrawImage(ImageIndex: TSnakeImage);
    begin
        Grid.Canvas.StretchDraw(Rect, TBitmap(FResourceImages[Integer(ImageIndex)]));
    end;

begin
    with GridData[ARow + 1, ACol + 1] do
    begin
        case GridValue of
            gvSnake1, gvSnake2:
                begin
                    Grid.Canvas.Brush.Color := cSNAKE_COLOR[Snake.No, Snake.Body[BodyIndex].DataType];
                    DrawImage(Snake.GetImageIndex(BodyIndex));
                    Grid.Canvas.FloodFill(Rect.Left + ((Rect.Right - Rect.Left) div 2),
                        (Rect.Top + (Rect.Bottom - Rect.Top) div 2), $00008284, fsSurface);
                end;
            gvFood:
                begin
                    Grid.Canvas.Brush.Color := cGRID_COLORS[gvEmpty];
                    DrawImage(imFood);
                end;
            gvBug:
                begin
                    Grid.Canvas.Brush.Color := cGRID_COLORS[gvEmpty];
                    DrawImage(imBug);
                end;
        else
            Grid.Canvas.Brush.Color := cGRID_COLORS[GridValue];
            Grid.Canvas.FillRect(Rect);
        end;
    end;
end;

procedure TfrmSnakeMain.EmptyGridData;
var
    x, y            : Integer;
begin
    for x := Low(GridData) to High(GridData) do
        for y := Low(GridData[0]) to High(GridData[0]) do
            with GridData[x, y] do
            begin
                GridValue := gvEmpty;
                Snake := nil;
                BodyIndex := 0;
            end;
    GridData[FBug.Row, FBug.Col].GridValue := gvEmpty;
end;

procedure TfrmSnakeMain.FormResize(Sender: TObject);
begin
    Grid.DefaultColWidth := (Grid.Width div Grid.ColCount) - Grid.GridLineWidth;
    Grid.DefaultRowHeight := (Grid.Height div Grid.RowCount) - Grid.GridLineWidth;
end;

procedure TfrmSnakeMain.GameOver;
var
    i               : Integer;
    sMsg            : string;
begin
    OnKeyDown := nil;
    tmrInterrupt.Enabled := False;
    tmrBug.Enabled := False;
    FStop := True;
    for i := 1 to 8 do
    begin
        Grid.Repaint;
        doDrawSnake(snkPlayer1, i mod 2 = 0);
        Sleep(200);
    end;
    sMsg := cGAME_OVER;
    if snkPlayer1.Score > HiScore then
        sMsg := sMsg + ' - HI SCORE';
    Grid.Canvas.Font := Grid.Font;
    Grid.Canvas.Brush.Color := clWindow;
    Grid.Canvas.TextOut((Grid.Width - Grid.Canvas.TextWidth(sMsg)) div 2,
        (Grid.Height - Grid.Canvas.TextHeight(sMsg)) div 2, sMsg);

    if snkPlayer1.Score > HiScore then
        HiScore := snkPlayer1.Score;
    tbLevel.Enabled := True;
    btnStart.Enabled := True;
end;

procedure TfrmSnakeMain.tmrInterruptTimer(Sender: TObject);
begin
    tmrInterrupt.Enabled := False;
    try
        CheckKeys;
        snkPlayer1.Move;
        DoBuildGridData;
        DoDrawSnake(snkPlayer1);
        Grid.Invalidate;
    finally
        tmrInterrupt.Enabled := not FStop;
    end;
end;

procedure TfrmSnakeMain.btnStartClick(Sender: TObject);
begin
    FKeyList.Clear;
    OnKeyDown := FormKeyDown;
    tbLevelChange(Self);
    UpdateScore(lbScoreP1, 0);
    btnStart.Enabled := False;
    tbLevel.Enabled := False;
    FreeAndNil(snkPlayer1);
    snkPlayer1 := TSnake.Create(1, cSNAKE1_START, cSNAKE_LENGTH, sdRight);
    doInitialise;
    doDrawSnake(snkPlayer1);
    doGetFood;
    tmrInterrupt.Enabled := True;
end;

procedure TfrmSnakeMain.doGetFood;
begin
    FFood := GetEmptyPoint;
end;

procedure TfrmSnakeMain.doFoodEaten(ASnake: TSnake);
begin
    ASnake.Score := ASnake.Score + tbLevel.Position;
    UpdateScore(lbScoreP1, ASnake.Score);
    if ASnake.Score > HiScore then
    begin
        HiScore := ASnake.Score;
        UpdateScore(lbHiScoreP1, ASnake.Score);
    end;
    ASnake.AddBody;
    doGetFood;
    doGetBug;
end;

procedure TfrmSnakeMain.tbLevelChange(Sender: TObject);
begin
    tmrInterrupt.Interval := cSPEED[cLEVELS - tbLevel.Position + 1];
    tbLevel.Hint := Format('Difficulty: %d', [tbLevel.Position]);
end;

procedure TfrmSnakeMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if not FStop and Assigned(snkPlayer1) then
        FKeyList.Add(Pointer(Key));
end;

procedure TfrmSnakeMain.doGetBug;
begin
    Inc(FFoodEaten);
    if FFoodEaten mod 5 = 0 then
    begin
        FBug := GetEmptyPoint;
        FBugCountDown := cBUG_LIFE;
        tmrBug.Enabled := True;
    end;
end;

function TfrmSnakeMain.GetEmptyPoint: TSnakeGridCoord;
var
    iRow, iCol      : Integer;
    bDone           : Boolean;
begin
    bDone := False;
    while not bDone do
    begin
        iRow := Random(Grid.RowCount - 1) + 1;
        iCol := Random(Grid.ColCount - 1) + 1;
        if (GridData[iRow, iCol].GridValue = gvEmpty) and not Assigned(GridData[iRow, iCol].Snake) then
        begin
            bDone := True;
            Result.Row := iRow;
            Result.Col := iCol;
        end;
    end;
end;

procedure TfrmSnakeMain.doBugEaten(ASnake: TSnake);
begin
    ASnake.Score := ASnake.Score + cBUG_SCORE * FBugCountDown;
    UpdateScore(lbScoreP1, ASnake.Score);
    GridData[FBug.Row, FBug.Col].GridValue := gvEmpty;
    tmrBug.Enabled := False;
    frmSnakeMain.lbBugIndicator.Caption := '';
end;

procedure TfrmSnakeMain.UpdateScore(ALabel: TLabel; Value: Integer);
var
    sTmp            : string;
begin
    sTmp := IntToStr(Value);
    ALabel.Caption := StringOfChar('0', 6 - Length(sTmp)) + sTmp + ' ';
end;

procedure TfrmSnakeMain.tmrBugTimer(Sender: TObject);
begin
    Dec(FBugCountDown);
    tmrBug.Enabled := (FBugCountDown <> 0);
    if not tmrBug.Enabled then
        frmSnakeMain.lbBugIndicator.Caption := ''
    else
        frmSnakeMain.lbBugIndicator.Caption := Format('Bug: %d', [FBugCountDown]);
end;

procedure TfrmSnakeMain.SetHiScore(const Value: Integer);
begin
    FHiScore := Value;
    SaveHiScore(Value);
    UpdateScore(lbHiScoreP1, Value);
end;

function TfrmSnakeMain.LoadHiScore: Integer;
var
    Reg             : TRegistry;
begin
    Reg := TRegistry.Create;
    try
        if Reg.OpenKey(cREG_KEY, True) and Reg.ValueExists(cSCORE_VALUE) then
            Result := Reg.ReadInteger(cSCORE_VALUE)
        else
            Result := 0;
        Reg.CloseKey;
    finally
        Reg.Free;
    end;
    FHiScore := Result;
end;

procedure TfrmSnakeMain.SaveHiScore(const Value: Integer);
var
    Reg             : TRegistry;
begin
    Reg := TRegistry.Create;
    try
        if Reg.OpenKey(cREG_KEY, True) then
            Reg.WriteInteger(cSCORE_VALUE, Value);
        Reg.CloseKey;
    finally
        Reg.Free;
    end;
end;

procedure TfrmSnakeMain.CheckKeys;
var
    Key             : Integer;
begin
    if FKeyList.Count > 0 then
    begin
        Key := Integer(FKeyList[0]);
        case Key of
            VK_Up: snkPlayer1.Direction := sdUp;
            VK_Down: snkPlayer1.Direction := sdDown;
            VK_Left: snkPlayer1.Direction := sdLeft;
            VK_Right: snkPlayer1.Direction := sdRight;
        end;
        FKeyList.Delete(0);
    end;
end;

procedure TfrmSnakeMain.LoadAllResources;
var
    SnakeImage      : TSnakeImage;
    Bitmap          : TBitmap;
begin
    FResourceImages := TObjecTList.Create;
    for SnakeImage := Low(TSnakeImage) to High(SnakeImage) do
    begin
        Bitmap := TBitmap.Create;
        Bitmap.LoadFromResourceName(HInstance, cRESOURCE_NAME[SnakeImage]);
        Bitmap.TransparentColor := clWhite;
        Bitmap.Transparent := True;
        FResourceImages.Add(Bitmap);
    end;
end;

{ TSnake }

constructor TSnake.Create(ANo: Integer; StartingPoint: TSnakeData; iInitialLength: Integer; ADirection: TDirection);
var
    iLength         : Integer;
begin
    FNo := ANo;
    FScore := 0;
    FDirection := ADirection;
    Length := iInitialLength;
    Body[0] := StartingPoint;
    Body[0].DataType := dtTail;
    Body[0].Direction := ADirection;
    for iLength := 1 to iInitialLength - 2 do
    begin
        Body[iLength] := Body[iLength - 1];
        Body[iLength].Col := Body[iLength].Col + 1;
        Body[iLength].DataType := dtBody;
        Body[iLength].Direction := ADirection;
    end;
    Body[iInitialLength - 1].DataType := dtHead;
    Body[iInitialLength - 1].Row := Body[iInitialLength - 2].Row;
    Body[iInitialLength - 1].Col := Body[iInitialLength - 2].Col + 1;
    Body[iInitialLength - 1].Direction := ADirection;
end;

procedure TSnake.SetLength(const Value: Integer);
begin
    FLength := Value;
    System.SetLength(FBody, Value);
end;

procedure TSnake.SetDirection(const Value: TDirection);
begin
    if not (((Value in cV_DIRECTIONS) and (FDirection in cV_DIRECTIONS)) or
        ((Value in cH_DIRECTIONS) and (FDirection in cH_DIRECTIONS))) then
        FDirection := Value;
end;

procedure TSnake.AddBody;
begin
    Length := Length + 1;
    Body[Length - 1] := Body[Length - 2]; // make new head equal to old head
    Body[Length - 2].Direction := FLastDirection;
    Body[Length - 2].DataType := dtBody; // make old head into a body part
    Body[Length - 1].Direction := Direction; // ensure new head points in proper direction
end;

procedure TSnake.MoveBody(NewPoint: TSnakeData);
var
    iLength         : Integer;
begin
    for iLength := 0 to Length - 2 do
    begin
        Body[iLength].Row := Body[iLength + 1].Row;
        Body[iLength].Col := Body[iLength + 1].Col;
        Body[iLength].Direction := Body[iLength + 1].Direction;
    end;
    Body[Length - 1] := NewPoint;
end;

function TSnake.Head: TSnakeData;
begin
    Result := Body[Length - 1];
end;

procedure TSnake.Move;
var
    AHead           : TSnakeData;
begin
    AHead := Head;
    case Direction of
        sdUp: Dec(AHead.Row);
        sdDown: Inc(AHead.Row);
        sdLeft: Dec(AHead.Col);
        sdRight: Inc(AHead.Col);
    end;
    Body[Length - 1].Direction := Self.Direction;
    with frmSnakeMain do
    begin
        if AHead.Row < 1 then AHead.Row := Grid.RowCount;
        if AHead.Row > Grid.RowCount then AHead.Row := 1;
        if AHead.Col < 1 then AHead.Col := Grid.ColCount;
        if AHead.Col > Grid.ColCount then AHead.Col := 1;
    end;
    TestForCollision(AHead);
    FLastDirection := FDirection;
    MoveBody(AHead);
end;

procedure TSnake.TestForCollision(AHead: TSnakeData);
begin
    with frmSnakeMain, GridData[AHead.Row, AHead.Col] do
        case GridValue of
            gvFood: doFoodEaten(Self);
            gvBug: doBugEaten(Self);
            gvWall, gvSnake1, gvSnake2:
                if (GridValue = gvWall) or (not ((Snake = Self) and (Snake.Body[BodyIndex].DataType = dtTail))) then
                    raise ECollission.Create;
        end;
end;

function TSnake.GetImageIndex(Position: Integer): TSnakeImage;
begin
    Result := imBODY_HORZ;
    if (Position = Length - 1) then
    begin
        if not frmSnakeMain.FStop then
            Result := TSnakeImage(Integer(Direction) + 0)
        else
            Result := TSnakeImage(Integer(FLastDirection) + 0) // Display the last direction after a collision
    end
    else
        if Position = 0 then
            Result := TSnakeImage(Integer(Body[Position].Direction) + 4)
        else
            if Body[Position - 1].Direction = Body[Position].Direction then
                // same direction, set as BODY_HORZ or BODY_VERT
                if Body[Position - 1].Direction in cH_DIRECTIONS then
                    Result := imBODY_HORZ
                else
                    Result := imBODY_VERT
            else
                case Body[Position - 1].Direction of
                    sdUp:
                        case Body[Position].Direction of
                            sdLeft: Result := imBODY_DL;
                            sdRight: Result := imBODY_DR;
                        end;
                    sdDown:
                        case Body[Position].Direction of
                            sdLeft: Result := imBODY_UL;
                            sdRight: Result := imBODY_UR;
                        end;
                    sdLeft:
                        case Body[Position].Direction of
                            sdUp: Result := imBODY_UR;
                            sdDown: Result := imBODY_DR;
                        end;                                                   
                    sdRight:
                        case Body[Position].Direction of
                            sdUp: Result := imBODY_UL;
                            sdDown: Result := imBODY_DL;
                        end;
                end;
end;

end.

