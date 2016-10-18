#Some enhancements to standard classes created to fit my needs
require 'active_support/inflector'

class Pathname
  # Adds new method to Pathname, which removes accented characters from Pathname. Then removes spaces and any special characters (they are replaced by _). This method returns another Pathname
  def no_special_chars
    transliterated=ActiveSupport::Inflector.transliterate(self.to_s)
    return Pathname.new(transliterated.gsub!(/[^0-9A-Za-z\/.]/, '_'))
  end

  # Adds new method to Pathname, which can check if path itself is child of root (root is another Pathname)
  # It is used in Track class to determine if track initialization is is correct (if file is really located in defined directory)
  def is_child?(root)
    if self.to_s.size >= root.to_s.size
      return self.to_s[0...root.to_s.size] == root.to_s && (self.to_s.size == root.to_s.size || self.to_s[root.to_s.size] == ?/ )
    else
      return false
    end
  end

end
