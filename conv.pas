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

begin
  try
    
    var Settings := new Dictionary<string, object>;
    with new class(sr := new System.IO.StreamReader(System.IO.File.OpenRead('settings.cfg'))) do
      while not sr.EndOfStream do
      begin
        var l := sr.ReadLine.Split('=');
        l[0] := l[0].TrimEnd(#9);
        case l[0] of
          
          'convert colors': Settings['ccl'] := boolean.Parse(l[1]);
          'resize':         Settings['rsz'] := boolean.Parse(l[1]);
        
        else raise new Exception('wrong setting name');//делать свои типы исключений? неее)))) не в такой проге
        end;
      end;
    
    
    
    var b := new Bitmap('in.bmp');
    if boolean(Settings['rsz']) then b := new Bitmap(b, 53, 7);
    
    
    
    var sw := System.IO.File.CreateText('temp.otp.txt');
    sw.WriteLine('<g transform="translate(16, 20)">');
    
    var ccl := boolean(Settings['ccl']);
    
    for var x := 0 to b.Width - 1 do
    begin
      sw.WriteLine($'<g transform="translate({x*11}, 0)">');
      
      for var y := 0 to b.Height - 1 do
        sw.WriteLine(
 	        $'<rect class="day" width="8" height="8" ' +
 	        $'x="{11-x}" ' +
 	        $'y="{y*10}" ' +
 	        $'fill="#{ccl?find_color(b.GetPixel(x,y)):(b.GetPixel(x,y).ToArgb and $FFFFFF).ToString(''x'').PadLeft(6,''0'')}" ' +
 	        $'data-count="0" data-date="2017-10-29"></rect>');
      
      sw.WriteLine('</g>');
    end;
    
    sw.WriteLine(
    	   '<text x="21" y="-8" class="month">Nov</text>'
    	#10'<text x="61" y="-8" class="month">Dec</text>'
    	#10'<text x="111" y="-8" class="month">Jan</text>'
    	#10'<text x="151" y="-8" class="month">Feb</text>'
    	#10'<text x="191" y="-8" class="month">Mar</text>'
    	#10'<text x="231" y="-8" class="month">Apr</text>'
    	#10'<text x="281" y="-8" class="month">May</text>'
    	#10'<text x="321" y="-8" class="month">Jun</text>'
    	#10'<text x="361" y="-8" class="month">Jul</text>'
    	#10'<text x="411" y="-8" class="month">Aug</text>'
    	#10'<text x="451" y="-8" class="month">Sep</text>'
    	#10'<text x="501" y="-8" class="month">Oct</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="8" style="display: none;">Sun</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="17">Mon</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="32" style="display: none;">Tue</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="37">Wed</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="57" style="display: none;">Thu</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="57">Fri</text>'
    	#10'<text text-anchor="start" class="wday" dx="-12" dy="81" style="display: none;">Sat</text>'
      #10'</g>'
    );
    
    
    
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