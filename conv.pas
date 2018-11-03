program conv;

{$reference System.Drawing.dll}
uses System.Drawing;

var
  std_clrs := Arr(
    new class(r := $eb, g := $ed, b := $f0),
    new class(r := $c6, g := $e4, b := $8b),
    new class(r := $7b, g := $c9, b := $6f),
    new class(r := $23, g := $9a, b := $3b),
    new class(r := $19, g := $61, b := $27)
  );

function find_color(c: Color):string;
begin
  var nc := std_clrs.MinBy(cc -> sqrt(sqr(c.R - cc.r) + sqr(c.G - cc.g) + sqr(c.B - cc.b)));
  Result :=
    nc.r.ToString('x').PadLeft(2, '0') +
    nc.g.ToString('x').PadLeft(2, '0') +
    nc.b.ToString('x').PadLeft(2, '0');
end;

type
  dow = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
  moy = (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec);

begin
  try
    
    var cfg := new class(
      
      rsz := true,
      ccl := true,
      
      dx := 0,
      dy := 0,
      cw := 0,
      ch := 0,
      
      amd := true,
      
      sm := 0,
      mxs := new integer[12],
      my := 0,
      
      sd := 0,
      dds := new boolean[7],
      ddys := new integer[7],
      ddx := 0
      
    );
    
    
    with new class(sr := new System.IO.StreamReader(System.IO.File.OpenRead('settings.cfg'))) do
      while not sr.EndOfStream do
      begin
        var l := sr.ReadLine.Split('=');
        if l[0] = '' then continue;
        l[0] := l[0].TrimEnd(#9);
        case l[0] of
          
          'convert colors': cfg.ccl := boolean.Parse(l[1]);
          'resize':         cfg.rsz := boolean.Parse(l[1]);
          
          'dx':             cfg.dx := l[1].ToInteger;
          'dy':             cfg.dy := l[1].ToInteger;
          'cw':             cfg.cw := l[1].ToInteger;
          'ch':             cfg.ch := l[1].ToInteger;
          
          'add m/d':        cfg.amd := boolean.Parse(l[1]);
          
          'start month':    cfg.sm := l[1].ToInteger;
          'dow-display':    cfg.dds := l[1].Split(' ').ConvertAll(boolean.Parse);
          'month-x''s':     cfg.mxs := l[1].ToIntegers;
          'month-y':        cfg.my := l[1].ToInteger;
          
          'start day':      cfg.sd := l[1].ToInteger;
          'day-y''s':       cfg.ddys := l[1].ToIntegers;
          'day-x':          cfg.ddx := l[1].ToInteger;
          
        else raise new Exception($'wrong setting name: {l[0]}');//делать свои типы исключений? неее)))) не в такой проге
        end;
      end;
    
    
    
    var b := new Bitmap('in.bmp');
    if cfg.rsz then b := new Bitmap(b, 53, 7);
    
    
    
    var sw := System.IO.File.CreateText('temp.otp.txt');
    sw.WriteLine('<g transform="translate(16, 20)">');
    
    for var x := 0 to b.Width - 1 do
    begin
      sw.WriteLine($'<g transform="translate({x*11}, 0)">');
      
      for var y := 0 to b.Height - 1 do
        sw.WriteLine(
 	        $'<rect class="day" width="{cfg.cw}" height="{cfg.ch}" ' +
 	        $'x="{cfg.dx-x}" ' +
 	        $'y="{y*cfg.dy}" ' +
 	        $'fill="#{cfg.ccl?find_color(b.GetPixel(x,y)):(b.GetPixel(x,y).ToArgb and $FFFFFF).ToString(''x'').PadLeft(6,''0'')}" ' +
 	        $'data-count="0" data-date="2017-10-29"></rect>');
      
      sw.WriteLine('</g>');
    end;
    
    
    
    if cfg.amd then
    begin
      
      for var i := 0 to 11 do
        sw.WriteLine($'<text x="{cfg.mxs[i]}" y="{cfg.my}" class="month">{moy.GetName(typeof(moy),(cfg.sm+i) mod 12)}</text>');
      
      for var i := 0 to 6 do
      begin
        sw.Write($'<text text-anchor="start" class="wday" ');
        sw.Write($'dx="{cfg.ddx}" dy="{cfg.ddys[i]}"');
        if not cfg.dds[i] then sw.Write($' style="display: none;"');
        sw.WriteLine($'>{dow.GetName(typeof(dow),(cfg.sd+i) mod 7)}</text>');
      end;
      
    end;
    
    
    
    sw.WriteLine('</g>');
    
    sw.Flush;
    Exec('temp.otp.txt');
    
    Halt;
  except
    on e: Exception do
    begin
      Writeln(e);
      Readln;
      Halt;
    end;
  end;
end.