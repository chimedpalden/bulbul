class Cosine
  def initialize vecA, vecB
    @vecA = vecA
    @vecB = vecB
  end

  def vector_similarity
    if !@vecA.is_a?(Array) || !@vecB.is_a?(Array) || (@vecA.size != @vecB.size)
      return nil
    else
      dot_product = @vecA.zip(@vecB).map{|x,y| x*y}.sum
      norm1 = Math.sqrt(@vecA.map{|x| x**2}.sum)
      norm2 = Math.sqrt(@vecB.map{|x| x**2}.sum)
      return dot_product / (norm1 * norm2)
    end
  end
end