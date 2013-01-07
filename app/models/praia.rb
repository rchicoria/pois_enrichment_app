# encoding: UTF-8
class Praia < Local

	def descricao()
		return "Esta praia não possui bandeira azul." if not self.bandeira_azul
		return "Esta praia é classificada com bandeira azul."
	end

end
