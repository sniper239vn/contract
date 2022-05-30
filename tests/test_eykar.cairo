%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from contracts.eykar import (
    mint,
    expand,
    conquer,
    get_player_colonies,
    current_registration_id,
    get_colony,
    get_plot,
)
from contracts.convoys.library import move_convoy

@view
func test_mint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}
    let (caller) = get_caller_address()

    let (size : felt, colonies : felt*) = get_player_colonies(caller)
    assert size = 0

    mint(448378203247)
    mint(512970878052)

    let (colonies_len : felt, colonies : felt*) = get_player_colonies(caller)
    assert colonies_len = 2
    assert [colonies] = 1
    assert [colonies + 1] = 2
    %{ stop_prank_callable() %}
    return ()
end

@view
func test_expand{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    %{ stop_prank_callable = start_prank(123) %}
    let (caller) = get_caller_address()

    let (size : felt, colonies : felt*) = get_player_colonies(caller)
    assert size = 0

    mint(448378203247)

    let (colonies_len : felt, colonies : felt*) = get_player_colonies(caller)
    assert colonies_len = 1
    assert [colonies] = 1

    expand(1, 0, 0, 1, 0)
    let (plot) = get_plot(1, 0)
    assert plot.owner = 1

    %{ stop_prank_callable() %}
    return ()
end

@view
func test_conquer{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    %{
        stop_prank_callable = start_prank(123)
        warp(0)
    %}
    let (caller) = get_caller_address()

    let (size : felt, colonies : felt*) = get_player_colonies(caller)
    assert size = 0

    mint(448378203247)

    let (colonies_len : felt, colonies : felt*) = get_player_colonies(caller)
    assert colonies_len = 1
    assert [colonies] = 1
    %{ warp(1) %}
    move_convoy(1, 0, 0, 3, -4)
    %{ warp(1000000) %}
    conquer(1, 3, -4, 512970878052)
    let (colonies_len : felt, colonies : felt*) = get_player_colonies(caller)
    assert colonies_len = 2
    assert [colonies] = 1
    assert [colonies + 1] = 2
    %{ stop_prank_callable() %}
    return ()
end
