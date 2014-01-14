module Puppet::Parser::Functions
  newfunction(:gen_instances, :type => :rvalue, :doc => <<-EOS
Takes the number of instances as the first argument, base protocol buffer
port as the second, base http port as the third, base handoff port as the
fourth, and install_dir as the fifth.  It will return a hash to be used with
create_resources for creating dev riak instances.
    EOS
  ) do |args|
    raise(Puppet::ParseError, "gen_instances(): Wrong number of arguments " +
      "given (#{arguments.size} for 6)") if args.size != 6

    instances     = args[0].to_i
    base_pb       = args[1].to_i - 1
    base_http     = args[2].to_i - 1
    base_handoff  = args[3].to_i - 1
    install_dir   = args[4]
    monitoring    = args[5]
    result        = {}

    (1..instances).each do |instance|
      result["dev#{instance}"] = {}
      result["dev#{instance}"]['instance']      = instance
      result["dev#{instance}"]['pb_port']       = base_pb + instance
      result["dev#{instance}"]['http_port']     = base_http + instance
      result["dev#{instance}"]['handoff_port']  = base_handoff + instance
      result["dev#{instance}"]['install_dir']   = install_dir
      result["dev#{instance}"]['monitoring']    = monitoring
    end

    return result
  end
end
