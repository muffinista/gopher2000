class String
  # Wraps a string to +width+ characters and returns the text with newlines inserted
  # If +block+ is given, yields each line for you to play around with
  def wrap(width=80, &block)
    text = self.dup
    p = text.rindex(' ', width) # Position of the last space
    wrap = text.jlength > width && p # Do we wrap?
    if block_given?
      if wrap # Only wrap if the text is long enough and has spaces
        yield text[0,p]
        text[p+1..-1].wrap(width, &block)
      else
        yield text
      end
    else
      return text unless wrap
      "#{text[0,p]}\n#{text[p+1..-1].wrap(width)}"
    end
  end
end
