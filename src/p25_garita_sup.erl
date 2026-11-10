-module(p25_garita_sup).
-behaviour(supervisor).
-export([start_link/1, init/1]).
start_link(Garita) -> supervisor:start_link({local, list_to_atom("sup_" ++ atom_to_list(Garita))}, ?MODULE, Garita).
init(Garita) ->
    Carriles = [general, ready_lane, sentri],
    Children = [#{id => {carril, C}, start => {p25_carril_server, start_link, [Garita, C]}, restart => permanent, shutdown => 5000, type => worker} || C <- Carriles],
    {ok, {#{strategy => one_for_one, intensity => 10, period => 60}, Children}}.
