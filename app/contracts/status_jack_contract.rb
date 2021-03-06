require 'obvious'

require_relative '../entities/status'

class StatusJackContract < Contract

  contract_for :save, {
    :input  => Status.shape,
    :output => Status.shape,
  }

  contract_for :get, {
    :input  => { :id => Fixnum },
    :output => Status.shape,
  }

  contract_for :list, {
    :output => [ Status.shape ],
    :input  => nil,
  }

  contract_for :remove, {
    :input  => { :id => Fixnum },
    :output => true,
  }

end
