-module(p25_garitas_db).
-export([init/0, guardar_lectura/3, obtener_historial/2]).
-define(TABLA, garitas_historial).
init() -> ets:new(?TABLA, [named_table, public, set, {read_concurrency, true}]).
guardar_lectura(Garita, Carril, Espera) ->
    Llave = {Garita, Carril},
    Timestamp = erlang:system_time(second),
    NuevaLectura = {Timestamp, Espera},
    Historial = case ets:lookup(?TABLA, Llave) of
        [{_, H}] -> H;
        [] -> []
    end,
    NuevoHistorial = lists:sublist([NuevaLectura | Historial], 10),
    ets:insert(?TABLA, {Llave, NuevoHistorial}),
    ok.
obtener_historial(Garita, Carril) ->
    case ets:lookup(?TABLA, {Garita, Carril}) of
        [{_, H}] -> H;
        [] -> []
    end.
