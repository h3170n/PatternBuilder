unit Tests.SSPatternBuilder;

interface

uses
  Classes, SysUtils, TestFrameWork, SSRegEx, SSPatternBuilder;

type
  TSSPatternBuilderTests = class(TTestCase)
  public
    P: TSSPatternBuilder;
  published
    procedure DoComplexTests;
    procedure TestEndsWith;
    procedure TestGroup;
    procedure TestJoinLists;
    procedure TestList;
    procedure TestNegate_with_list;
    procedure TestNegate_with_values;
    procedure TestOptional;
    procedure TestRange;
    procedure TestRepeatIt_with_n_times;
    procedure TestRepeatIt_with_range;
    procedure TestRepeatIt_zero_or_more;
    procedure TestRepeatItAtLeast;
    procedure TestRepeatItAtLeastOne;
    procedure TestRepeatItUntil;
    procedure TestStartsAndEndsWith;
    procedure TestStartsWith;
    procedure TestToPattern_array_of_char;
    procedure TestToPattern_String;
  end;

implementation

uses
  VCL.Dialogs;

{ TSSPatternBuilderTests }

procedure TSSPatternBuilderTests.DoComplexTests;
begin
  with P do
  begin
    { CPF test }
    CheckEquals(_CPF,
                StartsAndEndsWith(RepeatIt(RepeatIt(Digit, 3)+ToPattern('.'), 2)+RepeatIt(Digit, 3)+ToPattern('-')+RepeatIt(Digit, 2)),
                'Error on CPF test');

    //Telephone test
    CheckEquals(_Phone,
                StartsAndEndsWith(ToPattern('(')+RepeatIt(Digit, 2)+ToPattern(')')+Optional(ToPattern(' '))+RepeatIt(Digit, 4)+Optional(ToPattern('-'))+RepeatIt(Digit, 4)),
                'Error on phone test');
  end;
end;

procedure TSSPatternBuilderTests.TestEndsWith;
begin
  CheckEquals('MySimpleRegex$', P.EndsWith('MySimpleRegex'), 'Error on EndsWith');
end;

procedure TSSPatternBuilderTests.TestGroup;
begin
  CheckEquals('(MySimpleRegex)', P.Group('MySimpleRegex'), 'Error on Group');
end;

procedure TSSPatternBuilderTests.TestJoinLists;
begin
  CheckEquals('[A-Za-z0-9]', P.JoinLists([P.UpperCaseLetter, P.LowerCaseLetter, P.Digit]), 'Error on JoinList');
end;

procedure TSSPatternBuilderTests.TestList;
begin
  CheckEquals('[AEIOU]', P.List(['A', 'E', 'I', 'O', 'U']), 'Error on List');
end;

procedure TSSPatternBuilderTests.TestNegate_with_list;
begin
  CheckEquals('[^AEIOU]', P.Negate(['A', 'E', 'I', 'O', 'U']), 'Error on Negate with list');
end;

procedure TSSPatternBuilderTests.TestNegate_with_values;
begin
  CheckEquals('[^AEIOU]', P.Negate('[AEIOU]'), 'Error on Negate with values');
end;

procedure TSSPatternBuilderTests.TestOptional;
begin
  CheckEquals('MySimpleRegex?', P.Optional('MySimpleRegex'), 'Error on Optional');
end;

procedure TSSPatternBuilderTests.TestRange;
begin
  CheckEquals(P.Digit,           P.Range('0', '9'), 'Error on Range [with Digit]');
  CheckEquals(P.UpperCaseLetter, P.Range('A', 'Z'), 'Error on Range [with UpperCaseLetter]');
  CheckEquals(P.LowerCaseLetter, P.Range('a', 'z'), 'Error on Range [with LowerCaseLetter]');
end;

procedure TSSPatternBuilderTests.TestRepeatItAtLeast;
begin
  CheckEquals('A{10,}', P.RepeatItAtLeast('A', 10), 'Error on RepeatItAtLeast [1]');
  CheckEquals('(AB){10,}', P.RepeatItAtLeast('AB', 10), 'Error on RepeatItAtLeast [2]');
  CheckEquals('[AB]{10,}', P.RepeatItAtLeast('[AB]', 10), 'Error on RepeatItAtLeast [3]');
end;

procedure TSSPatternBuilderTests.TestRepeatItAtLeastOne;
begin
  CheckEquals('A+', P.RepeatItAtLeastOne('A'), 'Error on RepeatItAtLeastOne [1]');
  CheckEquals('(AB)+', P.RepeatItAtLeastOne('AB'), 'Error on RepeatItAtLeastOne [2]');
  CheckEquals('[AB]+', P.RepeatItAtLeastOne('[AB]'), 'Error on RepeatItAtLeastOne [3]');
end;

procedure TSSPatternBuilderTests.TestRepeatItUntil;
begin
  CheckEquals('A{0,3}', P.RepeatItUntil('A', 3), 'Error on RepeatItUntil [1]');
  CheckEquals('(AB){0,3}', P.RepeatItUntil('AB', 3), 'Error on RepeatItUntil [2]');
  CheckEquals('[AB]{0,3}', P.RepeatItUntil('[AB]', 3), 'Error on RepeatItUntil [3]');
end;

procedure TSSPatternBuilderTests.TestRepeatIt_with_range;
begin
  CheckEquals('A{2,5}', P.RepeatIt('A', 2, 5), 'Error on RepeatIt with range [1]');
  CheckEquals('(AB){2,5}', P.RepeatIt('AB', 2, 5), 'Error on RepeatIt with range [2]');
  CheckEquals('[AB]{2,5}', P.RepeatIt('[AB]', 2, 5), 'Error on RepeatIt with range [3]');
end;

procedure TSSPatternBuilderTests.TestRepeatIt_with_n_times;
begin
  CheckEquals('A{4}', P.RepeatIt('A', 4), 'Error on RepeatIt n times [1]');
  CheckEquals('(AB){4}', P.RepeatIt('AB', 4), 'Error on RepeatIt n times [2]');
  CheckEquals('[AB]{4}', P.RepeatIt('[AB]', 4), 'Error on RepeatIt n times [3]');
end;

procedure TSSPatternBuilderTests.TestRepeatIt_zero_or_more;
begin
  CheckEquals('A*', P.RepeatIt('A'), 'Error on RepeatIt zero or more [1]');
  CheckEquals('(AB)*', P.RepeatIt('AB'), 'Error on RepeatIt zero or more [2]');
  CheckEquals('[a-z]*', P.RepeatIt('[a-z]'), 'Error on RepeatIt zero or more [3]');
end;

procedure TSSPatternBuilderTests.TestStartsAndEndsWith;
begin
  CheckEquals('^MySimpleRegex$', P.StartsAndEndsWith('MySimpleRegex'), 'Error on StartsAndEndsWith');
end;

procedure TSSPatternBuilderTests.TestStartsWith;
begin
  CheckEquals('^MySimpleRegex', P.StartsWith('MySimpleRegex'), 'Error on StartsWith');
end;

procedure TSSPatternBuilderTests.TestToPattern_array_of_char;
begin
  CheckEquals('[\^\.\\_az]', P.ToPattern(['^', '.', '\', '_', 'a', 'z']), 'Error on ToPattern [with array of char]');
end;

procedure TSSPatternBuilderTests.TestToPattern_String;
begin
  CheckEquals('This-is\*-my\[R-e-g-e-x\]\^2', P.ToPattern('This-is*-my[R-e-g-e-x]^2'), 'Error on ToPattern [with String]');
end;

initialization
  RegisterTests([TSSPatternBuilderTests.Suite]);

end.