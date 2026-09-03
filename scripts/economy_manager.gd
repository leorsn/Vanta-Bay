extends Node
class_name EconomyManager

signal balances_changed(cash: int, bank: int, rep: int)
signal transaction_posted(label: String, amount: int)

@export var starting_cash := 1500
@export var starting_bank := 0

var cash := 0
var bank := 0
var rep := 0
var transactions: Array[Dictionary] = []

func _ready() -> void:
    add_to_group("economy_manager")
    cash = starting_cash
    bank = starting_bank
    refresh_balances()

func award_mission(label: String, cash_amount: int, rep_amount: int) -> void:
    bank += max(cash_amount, 0)
    rep += max(rep_amount, 0)
    transactions.push_front({"label": label, "amount": cash_amount})
    transaction_posted.emit(label, cash_amount)
    refresh_balances()

func charge(label: String, amount: int) -> bool:
    amount = max(amount, 0)
    if bank < amount:
        return false
    bank -= amount
    transactions.push_front({"label": label, "amount": -amount})
    transaction_posted.emit(label, -amount)
    refresh_balances()
    return true

func refresh_balances() -> void:
    balances_changed.emit(cash, bank, rep)
