# EP4
# Lógica Computacional

ExUnit.start()

###########################################################
# I. FUNÇÕES DESENVOLVIDAS								  #
###########################################################

defmodule Chomsky do

	# Exercício 1
	# toChomsky
	# Realiza os cinco passos para transformar uma gramática livre de contexto qualquer na forma normal de Chomsky
	
	# r1 = [{"S", ["A", "S", "B"]}, {"A", ["a", "A", "S"]}, {"A", ["a"]}, {"A", []}, {"B", ["S", "b", "S"]}, {"B", ["A"]}, {"B", ["b", "b"]}]
	#Chomsky.toChomsky([{"S", ["A", "b", "C"]}, {"S", ["C", "S", "D"]}, {"B", ["C"]}, {"C", ["c"]}, {"A", ["a", "B"]}, {"B", []}, {"D", ["d"]}, {"B", ["d"]}], "S", ["a", "b", "c", "d"], ["S", "A", "B", "C"])
	
	def toChomsky(rules, init, terminals, nonTerminals) do
		rules 
		|> removeInitialChar(init) 
		|> removeNonIsolatedTerminals(terminals) 
		|> reduceNonTerminals(join(nonTerminals, ["S0"])) 
		|> removeEmptyRules(init) 
		|> removeUnitaryRules(terminals)
	end
	
	# JOIN
	# Esta função realiza a junção U de duas listas
	# Verifica que a os elementos a serem adicionado 
	# não estão já presentes na lista final
	def join(list, [h | t]) do
		if h not in list do
			join(list ++ [h], t)
		else
			join(list, t)
		end
	end

	def join(list, []) do
		list
	end
	
	# Passo 1: substituir  símbolo inicial da parte direita das regras

	# rules = [{"S", ["A"]}, {"A", ["A", "S"]}]
	# init = "S"
	
	# Novo símbolo: S0
	
	# 1. Substitui S na parte direita por S0
	# 2. Adiciona a regra S0 -> S
	
	def removeInitialChar(rules, init) do
		newRules = replaceInitOnRight(rules, init, [])
		cond do
			newRules != rules -> join(newRules, [{"S0", ["S"]}])
			true -> rules
		end
	end

	def replaceInitOnRight([h | t], init, newRules) do
		replaceInitOnRight(t, init, join(newRules, [{elem(h, 0), replaceElementInList(elem(h, 1), init, "S0", [])}]))
	end

	def replaceInitOnRight([], _, newRules) do
		newRules
	end

	def replaceElementInList([h | t], old, new, newList) do
		cond do
			h == old -> replaceElementInList(t, old, new, join(newList, [new]))
			true -> replaceElementInList(t, old, new, join(newList, [h]))
		end
	end

	def replaceElementInList([], _, _, newList) do
		newList
	end
	
	# Passo 2: substituir símbolos não terminais que não estão isolados
	
	# rules = [{"S", ["A"]}, {"A", ["b", "a", "B"]}]
	# terminals = ["a", "b"]
	
	# Novos símbolos: NT + "Símbolo terminal"
	
	# 1. Substitui "a" por "NTa"
	# 2. Adiciona regra NTA -> a
	
	def removeNonIsolatedTerminals(rules, terminals) do
		replaceNonIsolatedTerminalsOnRight(rules, terminals, [])
	end
	
	def replaceNonIsolatedTerminalsOnRight([h | t], terminals, newRules) do
		replaceNonIsolatedTerminalsOnRight(t, terminals, join(newRules, replaceTerminalsOnRight(h, terminals, [])))
	end
	
	def replaceNonIsolatedTerminalsOnRight([], _, newRules) do
		newRules
	end

	def replaceTerminalsOnRight(rule, [h | t], rulesToAdd) do
		newRule = {elem(rule, 0), replaceElementInList(elem(rule, 1), h, "NT" <> h, [])}
		cond do
			newRule != rule -> replaceTerminalsOnRight(newRule, t, join(rulesToAdd, [{"NT" <> h, [h]}]))
			true -> replaceTerminalsOnRight(rule, t, rulesToAdd)
		end
	end
	
	def replaceTerminalsOnRight(rule, [], rulesToAdd) do
		join([rule], rulesToAdd)
	end
	
	# Passo 3: reduzir para dois o número de símbolos no lado direito
	
	# rules = [{"A", ["D", "E", "F"]}, {"A", ["A", "B", "C"]}]
	# notTerminals = ["A", "B", "C", "D", "E", "F"]
	
	# Novos símbolos: T + "Símbolo não terminal"
	
	# 1. Substitui "A" por "TA"
	# 2. Adiciona regra NTA -> a
	
	def reduceNonTerminals(rules, nonTerminals) do
		iterateNonTerminals(rules, nonTerminals, [])
	end
	
	def iterateNonTerminals(rules, [nonTerminal | t], newRules) do
		iterateNonTerminals(rules, t, join(newRules, reduceNonTerminalRules(rules, nonTerminal, 1, newRules)))
	end
	
	def iterateNonTerminals(_, [], newRules) do
		newRules
	end
	
	def reduceNonTerminalRules([h | t], nonTerminal, count, newRules) do
		cond do
		nonTerminal == elem(h, 0) -> reduceNonTerminalRules(t, nonTerminal, count + 1, join(newRules, expandRule(h, nonTerminal, count, 1, [])))
		Enum.count(elem(h, 1)) < 3 -> reduceNonTerminalRules(t, nonTerminal, count, join(newRules, [h]))	
		true -> reduceNonTerminalRules(t, nonTerminal, count, newRules)
		end
	end
	
	def reduceNonTerminalRules([], _, _, newRules) do
		newRules
	end
	
	def expandRule(rule, nonTerminal, c1, c2, rulesToAdd) do
		cond do
		Enum.count(elem(rule, 1)) > 2 -> expandRule({nonTerminal <> Integer.to_string(c1) <> "_" <> Integer.to_string(c2), getTail(elem(rule, 1))}, nonTerminal, c1, c2 + 1, join(rulesToAdd, [{elem(rule, 0), [getHead(elem(rule, 1)), nonTerminal <> Integer.to_string(c1) <> "_" <> Integer.to_string(c2)]}]))
		true -> join(rulesToAdd, [rule])
		end
	end

	def getHead([h | _]) do
		h
	end

	def getTail([_ | t]) do
		t
	end
	
	# Passo 4 : remover regras vazias dos não terminais que não são o símbolo inicial
	# rules = [{"A", ["D"]}, {"D", []}] [{"A", ["B", "C"]}, {"B", []}]
	# init = "S"

	# 1. Procura transições do tipo A -> vazio
	# 2. Acrescenta as transições que possuem A uma outra transição sem A (S -> AB vira S -> B e S -> AB)
	
	def removeEmptyRules(rules, init) do
		iterateRules(rules, init, rules)
	end
	
	def iterateRules([h | t], init, newRules) do
		cond do
			elem(h, 1) == [] && elem(h, 0) != init -> # achou transição vazia
			expandedRules = expandEmptyRule(newRules, elem(h, 0), [])
			iterateRules(expandedRules, init, expandedRules)
			true -> iterateRules(t, init, newRules)
		end
	end
	
	def iterateRules([], _, newRules) do
		newRules
	end
	
	def expandEmptyRule([h | t], nonTerminal, newRules) do
		cond do
			elem(h, 0) == nonTerminal && elem(h, 1) == [] -> expandEmptyRule(t, nonTerminal, newRules) # não adiciona se é a transição vazias
			containsElement?(elem(h, 1), nonTerminal) -> expandEmptyRule(t, nonTerminal, join(newRules, [h, {elem(h, 0), removeElementInList(elem(h, 1), nonTerminal, [])}]))
			true -> expandEmptyRule(t, nonTerminal, join(newRules, [h]))
		end
	end
	
	def expandEmptyRule([], _, newRules) do
		newRules
	end
	
	def containsElement?([h | t], element) do
		cond do
			h == element -> true
			true -> containsElement?(t, element)
		end
	end
	
	def containsElement?([], _) do
		false
	end
	
	def removeElementInList([h | t], toRemove, newList) do
		cond do
			h == toRemove -> removeElementInList(t, toRemove, newList)
			true -> removeElementInList(t, toRemove, join(newList, [h]))
		end
	end

	def removeElementInList([], _, newList) do
		newList
	end
	
	# Passo 5: remover as regras unitárias NT -> NT
	# rules = [{"A", ["B"]}, {"B", ["b"]}]
	# terminals = ["b"]
	
	# 1 - Procura transições do tipo NT1 -> NT2
	# 2 - Procura transição NT2 -> NT3NT4 ou NT2 -> T
	# 3 - Substitui a transição
	
	def removeUnitaryRules(rules, terminals) do
		removeNTNT(rules, terminals, rules)
	end
	
	def removeNTNT([h | t], terminals, newRules) do
		cond do
			Enum.count(elem(h, 1)) == 1 && checkIfContainsAnyElement(elem(h, 1), terminals) == false -> 
			removeNTNT(t, terminals, removeElementInList(join(newRules, swapNT(newRules, terminals, elem(h, 0), getHead(elem(h, 1)), newRules)), h, []))
			true -> removeNTNT(t, terminals, newRules)
		end
	end
	
	def removeNTNT([], _, newRules) do
		newRules
	end

	def swapNT([h | t], terminals, leftElem, rightElem, rules) do
		cond do
			elem(h, 0) == rightElem && checkIfContainsAnyElement(elem(h, 1), terminals) == false && Enum.count(elem(h, 1)) == 1 -> swapNT(rules, terminals, leftElem, getHead(elem(h, 1)), rules)
			elem(h, 0) == rightElem && checkIfContainsAnyElement(elem(h, 1), terminals) == false -> [{leftElem, elem(h, 1)}]
			elem(h, 0) == rightElem -> [{leftElem, elem(h, 1)}]
			true -> swapNT(t, terminals, leftElem, rightElem, rules)
		end
	end
	
	def swapNT([], _, _, _, _) do	
		[]
	end
	
	def checkIfContainsAnyElement(list, [h | t]) do
		cond do
		Enum.member?(list, h) -> true
		true -> checkIfContainsAnyElement(list, t)
		end
	end
	
	def checkIfContainsAnyElement(_, []) do
		false
	end	
	
end

defmodule CYK do
	# Exercício 2
	# CYK
	~S"""
	def createFalseTable(n, n, r) do
		List.duplicate(List.duplicate(List.duplicate(False, r), n), n)
	end
	
	def initTable([h | t], count, table, terminals) do
		a = returnIndex(terminals, List.first(elem(h, 1)), 0)
		cond do
			Enum.count(elem(h, 1)) == 1 && a != -1 -> initTable(t, count + 1, setTrue(table, 1, a, count), terminals))
			true -> initTable(t, count + 1, table, terminals)
		end
	end
	
	def initTable([], _, table, _) do
		table
	end
	
	def setTrue(table, x, y, z) do
		List.replace_at(List.replace_at(List.replace_at(table, True, count), 
	end
	
	def returnIndex([h | t], element, count) do
		cond do
			h == element -> count
			true -> returnIndex(t, element, count + 1)
		end
	end
	
	def returnIndex([], _, _) do
		-1
	end
	"""
	
end

###########################################################
# II. CASOS DE TESTE									  #
###########################################################

defmodule Tests do
	use ExUnit.Case
	
	# toChomsky
	
	test "Remover S do lado direito 1" do 
    require IEx  
	assert Chomsky.removeInitialChar([{"S", ["A"]}, {"A", ["A", "S"]}], "S") == [{"S", ["A"]}, {"A", ["A", "S0"]}, {"S0", ["S"]}]
    end  
	
	test "Remover S do lado direito 2" do 
    require IEx  
	assert Chomsky.removeInitialChar([{"S", ["A"]}, {"A", ["A", "B"]}], "S") == [{"S", ["A"]}, {"A", ["A", "B"]}]
    end
	
	test "Substituição de terminais" do
	require IEx
	assert Chomsky.replaceTerminalsOnRight({"S", ["a", "b"]}, ["a", "b"], []) == [{"S", ["NTa", "NTb"]}, {"NTa", ["a"]}, {"NTb", ["b"]}]
	end
	
	test "Remover múltiplos terminais do lado direito 1" do
	require IEx
	assert Chomsky.removeNonIsolatedTerminals([{"S", ["a"]}, {"A", ["b", "B", "c"]}], ["a", "b", "c"]) == [{"S", ["NTa"]}, {"NTa", ["a"]}, {"A", ["NTb", "B", "NTc"]}, {"NTb", ["b"]}, {"NTc", ["c"]}]
	end
	
	test "Remover múltiplos terminais do lado direito 2" do
	require IEx
	assert Chomsky.removeNonIsolatedTerminals([{"S", ["A"]}, {"A", ["C", "B", "S"]}], ["a", "b", "c"]) == [{"S", ["A"]}, {"A", ["C", "B", "S"]}]
	end
	
	test "Expandir regra" do
	require IEx
	assert Chomsky.expandRule({"A", ["B", "C", "D"]}, "A", 1, 1, []) == [{"A", ["B", "A1_1"]}, {"A1_1", ["C", "D"]}]
	end
	
	test "Reduzir não terminais" do
	require IEx
	assert Chomsky.reduceNonTerminals([{"A", ["B", "C", "D"]}, {"A", ["E", "F", "G"]}, {"D", ["E", "F"]}], ["A", "B", "C", "D", "E", "F", "G"]) == [{"A", ["B", "A1_1"]}, {"A1_1", ["C", "D"]}, {"A", ["E", "A2_1"]}, {"A2_1", ["F", "G"]}, {"D", ["E", "F"]}]
	end
	
	test "Expandir regra vazia" do
	require IEx
	assert Chomsky.expandEmptyRule([{"A", ["B", "C"]}, {"B", []}], "B", []) == [{"A", ["B", "C"]}, {"A", ["C"]}]
	end
	
	test "Remover transições NT -> Vazio" do
	require IEx
	assert Chomsky.removeEmptyRules([{"S", []}, {"S", ["A", "B"]}, {"S", ["A", "c"]}, {"A", ["B", "C"]}, {"A", []}, {"B", ["A", "C"]}, {"B", ["b"]}, {"A", ["a"]}, {"C", ["c", "A"]}], "S") == [{"S", []}, {"S", ["A", "B"]}, {"S", ["B"]}, {"S", ["A", "c"]}, {"S", ["c"]}, {"A", ["B", "C"]}, {"B", ["A", "C"]}, {"B", ["C"]}, {"B", ["b"]}, {"A", ["a"]}, {"C", ["c", "A"]}, {"C", ["c"]}]
	end
	
	test "Caso A -> B -> C -> d" do
	require IEx
	assert Chomsky.swapNT([{"A", ["B"]}, {"C", ["c"]},{"B", ["C"]}], ["A", "B", "C"], "A", "B", [{"A", ["B"]}, {"B", ["C"]}, {"C", ["c"]}])
	end
	
	test "Remover transição unitária" do
	require IEx
	assert Chomsky.removeUnitaryRules([{"A", ["B"]}, {"B", ["b"]}], ["b"]) == [{"B", ["b"]}, {"A", ["b"]}]
	end
	
	test "Remover transição unitária 2" do
	require IEx
	assert Chomsky.removeUnitaryRules([{"A", ["B"]}, {"B", ["C", "D"]}, {"B", ["C"]}, {"C", ["D"]}, {"D", ["d"]}], ["a", "b", "c", "d"]) == [{"B", ["C", "D"]}, {"D", ["d"]}, {"A", ["C", "D"]}, {"B", ["d"]}, {"C", ["d"]}]
	end
	
	test "Forma Normal de Chomsky" do
	require IEx
	assert Chomsky.toChomsky([{"S", ["A", "S", "B"]}, {"A", ["a", "A", "S"]}, {"A", ["a"]}, {"A", []}, {"B", ["S", "b", "S"]}, {"B", ["A"]}, {"B", ["b", "b"]}], "S", ["a", "b"], ["S", "A", "B"]) == [
              {"S", ["A", "S1_1"]},
              {"S1_1", ["S0", "B"]},
              {"NTa", ["a"]},
              {"B", ["S0", "NTb"]},
              {"NTb", ["b"]},
              {"A", ["NTa", "A1_1"]},
              {"A1_1", ["A", "S0"]},
              {"S", ["S0", "B"]},
              {"S1_1", ["A", "S1_1"]},
              {"A", ["a"]},
              {"B", ["NTa", "A1_1"]},
              {"B", ["b"]},
              {"S0", ["A", "S1_1"]},
              {"A1_1", ["A", "S1_1"]}
            ]
	end
	
end

ExUnit.Server.modules_loaded()

ExUnit.run()
