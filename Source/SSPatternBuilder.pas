unit SSPatternBuilder;

interface

uses
  System.RegularExpressions,
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  System.Generics.Defaults;

type
  TSSPatternBuilder = record
    const
      { Predefined regular expressions }
      _CPF            = '^([0-9]{3}\.){2}[0-9]{3}-[0-9]{2}$';
      _Phone          = '^\([0-9]{2}\) ?[0-9]{4}-?[0-9]{4}$';

      Any             = '.';
      Digit           = '[0-9]';
      Letter          = '[A-Za-z]';
      UpperCaseLetter = '[A-Z]';
      LowerCaseLetter = '[a-z]';
      All             = '.*';
    class function EndsWith(aPattern: String): String; static;
    class function Group(aPattern: String): String; static;
    class function JoinLists(aLists: array of String): String; static;
    class function List(aValues: array of Char): String; static;
    class function Negate(aList: String): String; overload; static;
    class function Negate(aValues: array of Char): String; overload; static;
    class function Optional(aPattern: String): String; static;
    class function Range(aFirst, aLast: Char): String; static;
    class function RepeatIt(aPattern: String): String; overload; static;
    class function RepeatIt(aPattern: String; aMin, aMax: Integer): String; overload; static;
    class function RepeatIt(aPattern: String; aTimes: Integer): String; overload; static;
    class function RepeatItAtLeast(aPattern: String; aMin: Integer): String; static;
    class function RepeatItAtLeastOne(aPattern: String): String; static;
    class function RepeatItUntil(aPattern: String; aMax: Integer): String; static;
    class function StartsAndEndsWith(aPattern: String): String; static;
    class function StartsWith(aPattern: String): String; static;
    class function ToPattern(aValue: String): String; overload; static;
    class function ToPattern(aValues: array of Char): String; overload; static;
  end;

implementation

  { Internal functions }
  function _CheckGroup(aPattern: String): String; forward;
  function _ExtractContentFromList(aList: String): String; forward;
  function _Group(aPattern: String): String; forward;
  function _RepeatList(aPattern: String; aMin, aMax: Integer): String; forward;

function _CheckGroup(aPattern: String): String;
begin
  Result := aPattern;
  if (aPattern.Length <> 1) and
     (not ((aPattern.Length = 2) and TRegEx.IsMatch(Result, '^\\.$'))) and
     (not TRegEx.IsMatch(Result, '^((\[.*\])|(\(.*\)))$')) then
    Result := _Group(aPattern);
end;

function _ExtractContentFromList(aList: String): String;
begin
  Result := TRegEx.Replace(aList, '^\[(.*)\]$', '\1');
end;

function _Group(aPattern: String): String;
begin
  Result := '('+aPattern+')';
end;

function _RepeatList(aPattern: String; aMin, aMax: Integer): String;
begin
  Result := _CheckGroup(aPattern) + '{';
  if aMin = aMax then
    Result := Result + IntToStr(aMin)
  else
    Result := Result + IfThen(aMin = -1, '', IntToStr(aMin))+','+IfThen(aMax = -1, '', IntToStr(aMax));
  Result := Result + '}';
end;

{ TSSPatternBuilder }

class function TSSPatternBuilder.EndsWith(aPattern: String): String;
begin
  Result := aPattern+'$';
end;

class function TSSPatternBuilder.Group(aPattern: String): String;
begin
  Result := _Group(aPattern);
end;

class function TSSPatternBuilder.JoinLists(aLists: array of String): String;
var
  CurrentList: String;
begin
  for CurrentList in aLists do
    Result := Result + _ExtractContentFromList(CurrentList);
  if not Result.IsEmpty then
    Result := '[' + Result + ']';
end;

class function TSSPatternBuilder.List(aValues: array of Char): String;

    function GetList: String;
    var
      Ch: Char;
    begin
      Result := '';
      for Ch in aValues do
        Result := Result + Ch;
    end;

begin
  Result := '['+GetList+']';
end;

class function TSSPatternBuilder.Negate(aValues: array of Char): String;
begin
  Result := Negate(List(aValues));
end;

class function TSSPatternBuilder.Negate(aList: String): String;
begin
  Result := '[^'+_ExtractContentFromList(aList)+']';
end;

class function TSSPatternBuilder.Optional(aPattern: String): String;
begin
  Result := aPattern+'?';
end;

class function TSSPatternBuilder.RepeatIt(aPattern: String; aMin,
  aMax: Integer): String;
begin
  Result := _RepeatList(aPattern, aMin, aMax);
end;

class function TSSPatternBuilder.RepeatIt(aPattern: String; aTimes: Integer): String;
begin
  Result := _RepeatList(aPattern, aTimes, aTimes);
end;

class function TSSPatternBuilder.RepeatIt(aPattern: String): String;
begin
  Result := _CheckGroup(aPattern)+'*';
end;

class function TSSPatternBuilder.RepeatItAtLeast(aPattern: String;
  aMin: Integer): String;
begin
  Result := _RepeatList(aPattern, aMin, -1);
end;

class function TSSPatternBuilder.RepeatItAtLeastOne(aPattern: String): String;
begin
  Result := _CheckGroup(aPattern)+'+';
end;

class function TSSPatternBuilder.Range(aFirst, aLast: Char): String;
begin
  Result := '['+aFirst+'-'+aLast+']';
end;

class function TSSPatternBuilder.RepeatItUntil(aPattern: String; aMax: Integer): String;
begin
  Result := _RepeatList(aPattern, 0, aMax);
end;

class function TSSPatternBuilder.StartsAndEndsWith(aPattern: String): String;
begin
  Result := StartsWith(EndsWith(aPattern));
end;

class function TSSPatternBuilder.StartsWith(aPattern: String): String;
begin
  Result := '^'+aPattern;
end;

class function TSSPatternBuilder.ToPattern(aValues: array of Char): String;

    function GetValuesToPattern: String;
    var
      Ch: Char;
    begin
      Result := '';
      for Ch in aValues do
        Result := Result + TRegEx.Escape(Ch, False);
    end;

begin
  Result := '['+GetValuesToPattern+']';
end;

class function TSSPatternBuilder.ToPattern(aValue: String): String;
begin
  Result := TRegEx.Escape(aValue, False);
end;

end.

