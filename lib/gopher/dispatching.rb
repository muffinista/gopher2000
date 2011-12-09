module Gopher
  module Dispatching
    def dispatch(raw)

      puts raw

      raw_selector, raw_input = raw.split("\t")
      selector = Gopher::Utils.sanitize_selector(raw_selector)
      receiver, *arguments = router.lookup(selector)
      puts "LOOKUP: #{receiver} #{arguments.inspect}"

      puts receiver

      case receiver
      when Gopher::InlineGophlet then receiver.with(router.owner, raw_input).call(*arguments)
      else
        receiver.dispatch("#{arguments}\t#{raw_input}")
      end
    end
  end
end
