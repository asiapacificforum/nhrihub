class Fixnum
  Words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
  def as_word
    Words[self]
  end
end
