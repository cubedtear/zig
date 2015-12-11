# Language Reference

## Primitive Numeric Types:

zig          |        C equivalent    | Description
-------------|------------------------|-------------------------------
        bool |                   bool |  unsigned 1-bit integer
          i8 |                 int8_t |    signed 8-bit integer
          u8 |                uint8_t |  unsigned 8-bit integer
         i16 |                int16_t |   signed 16-bit integer
         u16 |               uint16_t | unsigned 16-bit integer
         i32 |                int32_t |   signed 32-bit integer
         u32 |               uint32_t | unsigned 32-bit integer
         i64 |                int64_t |   signed 64-bit integer
         u64 |               uint64_t | unsigned 64-bit integer
         f32 |                  float |  32-bit IEE754 floating point
         f64 |                 double |  64-bit IEE754 floating point
        f128 |            long double | 128-bit IEE754 floating point
       isize |               intptr_t |   signed pointer sized integer
       usize |              uintptr_t | unsigned pointer sized integer
     c_short |                  short | for API compatibility with C
    c_ushort |         unsigned short | for API compatibility with C
       c_int |                    int | for API compatibility with C
      c_uint |           unsigned int | for API compatibility with C
      c_long |                   long | for API compatibility with C
     c_ulong |          unsigned long | for API compatibility with C
  c_longlong |              long long | for API compatibility with C
 c_ulonglong |     unsigned long long | for API compatibility with C

## Grammar

```
Root : many(TopLevelDecl) token(EOF)

TopLevelDecl : FnDef | ExternBlock | RootExportDecl | Use

Use : many(Directive) token(Use) token(String) token(Semicolon)

RootExportDecl : many(Directive) token(Export) token(Symbol) token(String) token(Semicolon)

ExternBlock : many(Directive) token(Extern) token(LBrace) many(FnDecl) token(RBrace)

FnProto : many(Directive) option(FnVisibleMod) token(Fn) token(Symbol) ParamDeclList option(token(Arrow) Type)

Directive : token(NumberSign) token(Symbol) token(LParen) token(String) token(RParen)

FnVisibleMod : token(Pub) | token(Export)

FnDecl : FnProto token(Semicolon)

FnDef : FnProto Block

ParamDeclList : token(LParen) list(ParamDecl, token(Comma)) token(RParen)

ParamDecl : token(Symbol) token(Colon) Type | token(Ellipsis)

Type : token(Symbol) | token(Unreachable) | token(Void) | PointerType | ArrayType

PointerType : token(Star) (token(Const) | token(Mut)) Type

ArrayType : token(LBracket) Type token(Semicolon) Expression token(RBracket)

Block : token(LBrace) list(option(Statement), token(Semicolon)) token(RBrace)

Statement : Label | VariableDeclaration token(Semicolon) | NonBlockExpression token(Semicolon) | BlockExpression

Label: token(Symbol) token(Colon)

VariableDeclaration : token(Let) option(token(Mut)) token(Symbol) (token(Eq) Expression | token(Colon) Type option(token(Eq) Expression))

Expression : BlockExpression | NonBlockExpression

NonBlockExpression : ReturnExpression | AssignmentExpression | AsmExpression

AsmExpression : token(Asm) option(token(Volatile)) token(LParen) token(String) option(AsmOutput) token(RParen)

AsmOutput : token(Colon) list(AsmOutputItem, token(Comma)) option(AsmInput)

AsmInput : token(Colon) list(AsmInputItem, token(Comma)) option(AsmClobbers)

AsmOutputItem : token(LBracket) token(Symbol) token(RBracket) token(String) token(LParen) token(Symbol) token(RParen)

AsmInputItem : token(LBracket) token(Symbol) token(RBracket) token(String) token(LParen) Expression token(RParen)

AsmClobbers: token(Colon) list(token(String), token(Comma))

AssignmentExpression : BoolOrExpression token(Equal) BoolOrExpression | BoolOrExpression

BlockExpression : IfExpression | Block

BoolOrExpression : BoolAndExpression token(BoolOr) BoolAndExpression | BoolAndExpression

ReturnExpression : token(Return) option(Expression)

IfExpression : token(If) Expression Block option(Else | ElseIf)

ElseIf : token(Else) IfExpression

Else : token(Else) Block

BoolAndExpression : ComparisonExpression token(BoolAnd) ComparisonExpression | ComparisonExpression

ComparisonExpression : BinaryOrExpression ComparisonOperator BinaryOrExpression | BinaryOrExpression

ComparisonOperator : token(BoolEq) | token(BoolNotEq) | token(BoolLessThan) | token(BoolGreaterThan) | token(BoolLessEqual) | token(BoolGreaterEqual)

BinaryOrExpression : BinaryXorExpression token(BinOr) BinaryXorExpression | BinaryXorExpression

BinaryXorExpression : BinaryAndExpression token(BinXor) BinaryAndExpression | BinaryAndExpression

BinaryAndExpression : BitShiftExpression token(BinAnd) BitShiftExpression | BitShiftExpression

BitShiftExpression : AdditionExpression BitShiftOperator AdditionExpression | AdditionExpression

BitShiftOperator : token(BitShiftLeft | token(BitShiftRight)

AdditionExpression : MultiplyExpression AdditionOperator MultiplyExpression | MultiplyExpression

AdditionOperator : token(Plus) | token(Minus)

MultiplyExpression : CastExpression MultiplyOperator CastExpression | CastExpression

MultiplyOperator : token(Star) | token(Slash) | token(Percent)

CastExpression : PrefixOpExpression token(as) Type | PrefixOpExpression

PrefixOpExpression : PrefixOp SuffixOpExpression | SuffixOpExpression

SuffixOpExpression : PrimaryExpression option(FnCallExpression | ArrayAccessExpression)

FnCallExpression : token(LParen) list(Expression, token(Comma)) token(RParen)

ArrayAccessExpression : token(LBracket) Expression token(RBracket)

PrefixOp : token(Not) | token(Dash) | token(Tilde)

PrimaryExpression : token(Number) | token(String) | KeywordLiteral | GroupedExpression | token(Symbol) | Goto

Goto: token(Goto) token(Symbol)

GroupedExpression : token(LParen) Expression token(RParen)

KeywordLiteral : token(Unreachable) | token(Void) | token(True) | token(False)
```

## Operator Precedence

```
x() x[]
!x -x ~x
as
* / %
+ -
<< >>
&
^
|
== != < > <= >=
&&
||
= += -=
```

## Literals

### Characters and Strings

                 | Example     | Characters  | Escapes        | Null Terminated
-------------------------------------------------------------------------------
 Byte            | 'H'         | All ASCII   | Byte           | No
 UTF-8 Bytes     | "hello"     | All Unicode | Byte & Unicode | No
 UTF-8 C string  | c"hello"    | All Unicode | Byte & Unicode | Yes

### Byte Escapes

      | Name
-----------------------------------------------
 \x7F | 8-bit character code (exactly 2 digits)
 \n   | Newline
 \r   | Carriage return
 \t   | Tab
 \\   | Backslash
 \0   | Null
 \'   | Single quote
 \"   | Double quote

### Unicode Escapes

          | Name
----------------------------------------------------------
 \u{7FFF} | 24-bit Unicode character code (up to 6 digits)

### Numbers

 Number literals | Example     | Exponentiation
-------------------------------------------
 Decimal integer | 98222       | N/A
 Hex integer     | 0xff        | N/A
 Octal integer   | 0o77        | N/A
 Binary integer  | 0b11110000  | N/A
 Floating-point  | 123.0E+77   | Optional