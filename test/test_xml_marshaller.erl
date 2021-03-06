%% Author: carl
%% Created: 06 Feb 2011
%% Description: TODO: Add description to test_xml_marshaller
-module(test_xml_marshaller).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").
-include("erl8583_marshallers.hrl").

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%

xml_marshal_simple_test() ->
	IsoMsg1 = erl8583_message:new(),
	IsoMsg2 = erl8583_message:set(0, "0200", IsoMsg1),
	Marshalled = erl8583_marshaller:marshal(IsoMsg2, ?MARSHALLER_XML),
	IsoMsg2 = erl8583_marshaller:unmarshal(Marshalled, ?MARSHALLER_XML).

xml_marshal_complex_test() ->
	BitMap = from_list([{1, "foo"}, {2, "bar"}]),
	IsoMsg = from_list([{0, "0100"}, {1, "0200"}, {3, "333333"}, {48, BitMap} ]),
	Marshalled = erl8583_marshaller:marshal(IsoMsg, ?MARSHALLER_XML),
	IsoMsg = erl8583_marshaller:unmarshal(Marshalled, ?MARSHALLER_XML).

xml_marshal_with_attributes_test() ->
	IsoMsg = erl8583_message:new(),
	IsoMsg2 = erl8583_message:set_attribute("outgoing", "true", IsoMsg),
	IsoMsg3 = erl8583_message:set(0, "0110", IsoMsg2),
	Marshalled = erl8583_marshaller:marshal(IsoMsg3, ?MARSHALLER_XML),
	IsoMsg3 = erl8583_marshaller:unmarshal(Marshalled, ?MARSHALLER_XML).

xml_marshal_complex_attributes_test() ->
	BitMap = from_list([{1, "foo"}, {2, "bar"}]),
	BitMap2 = set_attributes([{"foo","bar"},{"hello","world"}], BitMap),
	IsoMsg = from_list([{1, "0200"}, {3, "333333"}, {48, BitMap2} ]),
	IsoMsg2 = erl8583_message:set(0, "0110", IsoMsg),
	Marshalled = erl8583_marshaller:marshal(IsoMsg2, ?MARSHALLER_XML),
	IsoMsg3 = erl8583_marshaller:unmarshal(Marshalled, ?MARSHALLER_XML),
	[0, 1, 3, 48] = erl8583_message:get_fields(IsoMsg3),
	BitMap2b = erl8583_message:get(48, IsoMsg3),
	Attrs2b = lists:sort(erl8583_message:get_attribute_keys(BitMap2b)),
	Attrs2b = lists:sort(erl8583_message:get_attribute_keys(BitMap2)).


xml_marshal_complex_attributes_b_test() ->
	BitMap = from_list([{1, "foo"}, {2, "bar"}]),
	BitMap2 = set_attributes([{"foo","bar"},{"hello","world"}], BitMap),
	IsoMsg = from_list([{1, "0200"}, {3, "333333"}, {48, BitMap2} ]),
	IsoMsg2 = erl8583_message:set(0, "0110", IsoMsg),
	Marshalled = erl8583_marshaller_xml:marshal(IsoMsg2),
	IsoMsg3 = erl8583_marshaller_xml:unmarshal(Marshalled),
	[0, 1, 3, 48] = erl8583_message:get_fields(IsoMsg3),
	BitMap2b = erl8583_message:get(48, IsoMsg3),
	Attrs2b = lists:sort(erl8583_message:get_attribute_keys(BitMap2b)),
	Attrs2b = lists:sort(erl8583_message:get_attribute_keys(BitMap2)).

xml_marshal_binary_test() ->
	IsoMsg1 = erl8583_message:new(),
	IsoMsg2 = erl8583_message:set(0, "0200", IsoMsg1),
	IsoMsg3 = erl8583_message:set(52, <<1,2,3,4,5,6,7,255>>, IsoMsg2),
	Marshalled = erl8583_marshaller:marshal(IsoMsg3, ?MARSHALLER_XML),
	IsoMsg3 = erl8583_marshaller:unmarshal(Marshalled, ?MARSHALLER_XML).
	
%%
%% Local Functions
%%
from_list(List) ->
	from_list(List, erl8583_message:new()).

from_list([], Message) ->
	Message;
from_list([{Key, Value} | Tail], Message) ->
	from_list(Tail, erl8583_message:set(Key, Value, Message)).

set_attributes([], Message) ->
	Message;
set_attributes([{Key, Value} | Tail], Message) ->
	set_attributes(Tail, erl8583_message:set_attribute(Key, Value, Message)).

