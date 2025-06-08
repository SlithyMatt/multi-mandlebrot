{ Copyright 2025, Andrew C. Young }
{ License: MIT }

program Mandlebrot;

  var
    patterns: array[0..14] of Pattern;
    w: WindowPtr;
    startTime, endTime: longint;
  const
    step = 8;
    maxRows = 38;
    maxCols = 63;

  procedure InitPatterns;
  begin
{ Define which patterns we want to use for each value.}
{ See Inside Macintosh Volume I, page 474. }

    GetIndPattern(patterns[0], sysPatListID, 13);
    GetIndPattern(patterns[1], sysPatListID, 21);
    GetIndPattern(patterns[2], sysPatListID, 28);
    GetIndPattern(patterns[3], sysPatListID, 26);
    GetIndPattern(patterns[4], sysPatListID, 10);
    GetIndPattern(patterns[5], sysPatListID, 22);
    GetIndPattern(patterns[6], sysPatListID, 23);
    GetIndPattern(patterns[7], sysPatListID, 24);
    GetIndPattern(patterns[8], sysPatListID, 25);
    GetIndPattern(patterns[9], sysPatListID, 5);
    GetIndPattern(patterns[10], sysPatListID, 4);
    GetIndPattern(patterns[11], sysPatListID, 3);
    GetIndPattern(patterns[12], sysPatListID, 2);
    GetIndPattern(patterns[13], sysPatListID, 7);
    GetIndPattern(patterns[14], sysPatListID, 1);
  end;

  procedure CreateWindow;
    var
      r: Rect;
  begin
    r.top := 40;
    r.left := 6;
    r.bottom := 340;
    r.right := 506;

    w := NewWindow(nil, r, 'Mandlebrot by Andrew C. Young', TRUE, 0, nil, TRUE, noGrowDocProc);
    ShowWindow(w);
    SelectWindow(w);
    SetPort(w);
  end;

  procedure DrawMandlebrot;
    var
      row, col, i: integer;
      x, y, xz, yz, xt: real;
      r: Rect;
      p: Pattern;
  begin
    for row := 0 to maxRows do
      begin
        r.top := row * step;
        r.bottom := r.top + step;
        for col := 0 to maxCols do
          begin
            r.left := col * step;
            r.right := r.left + step;

            xz := (col * 3.5 / (maxCols + 1)) - 2.5;
            yz := (row * 2.3 / (maxRows + 1)) - 1;
            x := 0;
            y := 0;

            for i := 0 to 14 do
              begin
                p := patterns[i];
                if (x * x) + (y * y) > 4 then
                  FillRect(r, p);
                xt := (x * x) - (y * y) + xz;
                y := (2 * x * y) + yz;
                x := xt;
              end; {pattern}
          end; {column}
      end; {row}
  end; {DrawMandlebrot}

  procedure EventLoop;
    var
      event: EventRecord;
      done: boolean;
  begin
    done := false;
    while done = false do
      begin
        if GetNextEvent(mDownMask, event) then
          begin
            if TrackGoAway(w, event.where) then
              done := true;
          end; {GetNextEvent}
      end; {while not done}
  end; {EventLoop}

  procedure DrawTicks (t: longint);
    var
      secs: longint;
      s: Str255;
      r: Rect;
  begin
{ Approximately 60 ticks per second }
    secs := Round(t / 60);
    s := StringOf('Ticks : ', t, ', Seconds: ', secs);
    r.Top := 280;
    r.Left := 20;
    r.Bottom := 295;
    r.Right := r.Left + StringWidth(s) + 10;
    FillRect(r, white);
    PenSize(1, 1);
    FrameRect(r);
    MoveTo(r.Left + 5, r.Bottom - 3);
    DrawString(s);
  end;

begin
{Program entry point}
  InitPatterns;
  CreateWindow;
  startTime := TickCount;
  DrawMandlebrot;
  endTime := TickCount;
  DrawTicks(endTime - startTime);
  EventLoop;
  ExitToShell;
end.
