-module(p25_carril_server).
-behaviour(gen_server).
-export([start_link/2, registrar_lectura/2, obtener_estado/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
start_link(Garita, Carril) -> gen_server:start_link({local, nombre_proceso(Garita, Carril)}, ?MODULE, {Garita, Carril}, []).
nombre_proceso(Garita, Carril) -> list_to_atom("carril_" ++ atom_to_list(Garita) ++ "_" ++ atom_to_list(Carril)).
registrar_lectura(Garita, Carril) -> gen_server:cast(nombre_proceso(Garita, Carril), {nueva_lectura}).
obtener_estado(Garita, Carril) -> gen_server:call(nombre_proceso(Garita, Carril), obtener_estado).
init({Garita, Carril}) -> {ok, #{garita => Garita, carril => Carril, ultima_actualizacion => 0}}.
handle_cast({nueva_lectura}, State) ->
    EsperaSimulada = rand:uniform(40) + 20,
    p25_garitas_db:guardar_lectura(maps:get(garita, State), maps:get(carril, State), EsperaSimulada),
    NuevoState = State#{ultima_actualizacion => erlang:system_time(second)},
    {noreply, NuevoState}.
handle_call(obtener_estado, _From, State) ->
    Garita = maps:get(garita, State),
    Carril = maps:get(carril, State),
    UltimaAct = maps:get(ultima_actualizacion, State),
    Ahora = erlang:system_time(second),
    Respuesta = case (Ahora - UltimaAct) > 7200 of
        true -> #{estado => desconocido, mensaje => <<"Datos obsoletos">>};
        false -> 
            Historial = p25_garitas_db:obtener_historial(Garita, Carril),
            Promedio = calcular_promedio_movil(Historial),
            #{estado => ok, espera_actual => Promedio}
    end,
    {reply, Respuesta, State}.
handle_info(_Info, State) -> {noreply, State}.
calcular_promedio_movil([]) -> 0;
calcular_promedio_movil(Historial) ->
    Tiempos = [Espera || {_Ts, Espera} <- Historial],
    lists:sum(Tiempos) div length(Tiempos).
