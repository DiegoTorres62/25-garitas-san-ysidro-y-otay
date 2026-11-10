-module(p25_http_handler).
-export([init/2]).
init(Req0, State) ->
    Path = cowboy_req:path(Req0),
    Req1 = case Path of
        <<"/api/garitas">> ->
            EstSanYsidroGen = p25_carril_server:obtener_estado(san_ysidro, general),
            EstSanYsidroSentri = p25_carril_server:obtener_estado(san_ysidro, sentri),
            EstOtayGen = p25_carril_server:obtener_estado(otay, general),
            Body = jsx:encode([
                #{garita => <<"San Ysidro">>, carril => <<"General">>, datos => EstSanYsidroGen},
                #{garita => <<"San Ysidro">>, carril => <<"SENTRI">>, datos => EstSanYsidroSentri},
                #{garita => <<"Otay">>, carril => <<"General">>, datos => EstOtayGen}
            ]),
            cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Body, Req0);
        _ -> cowboy_req:reply(404, #{}, <<"Not Found">>, Req0)
    end,
    {ok, Req1, State}.
