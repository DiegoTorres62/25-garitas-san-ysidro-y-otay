-module(p25_garitas_san_ysidro_y_otay_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).
start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).
init([]) ->
    p25_garitas_db:init(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/api/garitas", p25_http_handler, []},
            {"/", cowboy_static, {priv_file, p25_garitas_san_ysidro_y_otay, "index.html"}},
            {"/[...]", cowboy_static, {priv_dir, p25_garitas_san_ysidro_y_otay, ""}}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    Garitas = [san_ysidro, otay],
    Children = [#{id => {sup_garita, G}, start => {p25_garita_sup, start_link, [G]}, restart => permanent, shutdown => infinity, type => supervisor} || G <- Garitas],
    {ok, {#{strategy => one_for_one, intensity => 10, period => 60}, Children}}.
