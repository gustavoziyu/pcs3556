# EP1
# Lógica Computacional
# Bruno Vasconcelos e Gustavo Wang

defmodule Closure do

	##################################################################
	# 						FUNÇÕES AUXILIARES                       #
	##################################################################

	# JOIN
	# Esta função realiza a junção U de duas relações
	# Verifica que a o par a ser adicionado não está presente na lista final

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

	# GET_TRANSITIONS
	# Retorna todas as transições 

	def getTransitions(transitions, {a, b}, [h | t], list) do
		cond do
			a == b -> getTransitions(transitions, {a, b}, t, list) # Caso seja uma relação reflexiva, vai para o próximo elemento
			b == elem(h, 0) -> getTransitions(join(transitions, [{a, elem(h, 1)}]), {a, elem(h, 1)}, list, list) # Caso ache transição, procura pela próxima se existir
			a == elem(h, 1) -> getTransitions(join(transitions, [{elem(h, 0), b}]), {elem(h, 0), b}, list, list) # Caso ache transição, procura pela próxima se existir
			true -> getTransitions(transitions, {a, b}, t, list) # Vai para o próximo elemento
		end
	end

	def getTransitions(transitions, {_a, _b}, [], _list) do
		transitions
	end

	##################################################################
	# 						FUNÇÕES DE FECHO                         #
	##################################################################

	# REFLEXIVE_CLOSURE
	# Retorna em closure os pares a serem adicionados para haver um fecho reflexivo na lista [h | t]

	def reflexiveClosure(closure, [h | t]) do
		reflexiveClosure(join(closure, [{elem(h, 0), elem(h, 0)}, {elem(h, 1), elem(h, 1)}]), t)
	end

	def reflexiveClosure(closure, []) do
		closure
	end

	# TRANSITIVE_CLOSURE
	# Retorna em closure o fecho transitivo da lista list

	def transitiveClosure(closure, list, [h | t]) do
		transitiveClosure(join(closure, getTransitions(closure, h, list, list)), join(list, closure), t)
	end

	def transitiveClosure(closure, list, []) do
		join(list, closure)
	end
	
	def transitiveClosure([], list, [_h | _t]) do
		list
	end

	# REFLEXIVE_TRANSITIVE_CLOSURE
	# Exibe o fecho transitivo reflexivo da lista list

	def reflexiveTransitiveClosure(list) do
		reflexiveClosure(join(list, transitiveClosure([], list, list)), list)
	end

end