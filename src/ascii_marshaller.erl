%% Author: carl
%% Created: 12 Feb 2011
%% Description: TODO: Add description to ascii_marshaller
-module(ascii_marshaller).

%%
%% Include files
%%


%%
%% Exported Functions
%%
-export([marshal/1, marshal/2]).

%%
%% API Functions
%%
marshal(Msg) ->
	marshal(Msg, iso8583_fields).

marshal(Msg, EncodingRules) ->
	Mti = iso8583_message:get(0, Msg),
	[0|Fields] = iso8583_message:get_fields(Msg),
	Mti ++ bitmap(Fields) ++ encode(Fields, Msg, EncodingRules).
	
%%
%% Local Functions
%%
bitmap([]) ->
	[];
bitmap(Fields) ->
	NumBitMaps = (lists:max(Fields) + 63) div 64,
	ExtensionBits = [Bit * 64 - 127 || Bit <- lists:seq(2, NumBitMaps)],
	BitMap = lists:duplicate(NumBitMaps * 8, 0),
	convert:string_to_ascii_hex(bitmap(lists:sort(ExtensionBits ++ Fields), BitMap)).

bitmap([], Result) ->
	Result;
bitmap([Field|Tail], Result) when Field > 0 ->
	ByteNum = (Field - 1) div 8,
	BitNum = 7 - ((Field - 1) rem 8),
	{Left, Right} = lists:split(ByteNum, Result),
	[ToUpdate | RightRest] = Right,
	bitmap(Tail, Left ++ ([ToUpdate + (1 bsl BitNum)]) ++ RightRest).

encode(Fields, Msg, EncodingRules) ->
	lists:reverse(encode(Fields, Msg, [], EncodingRules)).

encode([], _Msg, Result, _EncodingRules) ->
	Result;
encode([Field|Tail], Msg, Result, EncodingRules) ->
	Encoding = EncodingRules:get_encoding(Field),
	Value = iso8583_message:get(Field, Msg),
	EncodedValue = encode_field(Field, Encoding, Value),
	encode(Tail, Msg, lists:reverse(EncodedValue) ++ Result, EncodingRules).

encode_field(_Field, {n, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
encode_field(_Field, {n, lllvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 3) ++ Value;
encode_field(_Field, {ns, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
encode_field(_Field, {an, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
encode_field(_Field, {an, lllvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 3) ++ Value;
encode_field(_Field, {ans, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
encode_field(_Field, {ans, lllvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 3) ++ Value;
encode_field(_Field, {n, fixed, Length}, Value) when length(Value) =< Length ->
	IntValue = list_to_integer(Value),
	convert:integer_to_string(IntValue, Length);
encode_field(_Field, {an, fixed, Length}, Value) when length(Value) =< Length ->
	convert:pad_with_trailing_spaces(Value, Length);
encode_field(_Field, {ans, fixed, Length}, Value) when length(Value) =< Length ->
	convert:pad_with_trailing_spaces(Value, Length);
encode_field(_Field, {x_n, fixed, Length}, [Head | Value]) when Head =:= $C orelse Head =:= $D ->
	IntValue = list_to_integer(Value),
	[Head] ++ convert:integer_to_string(IntValue, Length);
encode_field(_Field, {z, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
encode_field(_Field, {b, Length}, Value) when size(Value) =:= Length ->
	convert:binary_to_ascii_hex(Value);
encode_field(Field, {custom, Marshaller}, Value) ->
	Marshaller:marshal(Field, Value).

	
