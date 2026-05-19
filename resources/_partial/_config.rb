# frozen_string_literal: true

property :broker_config, Hash, default: {}
property :log4j_config, [Hash, nil], default: nil

property :env_path, String, default: lazy {
  platform_family?('debian') ? '/etc/default/kafka' : '/etc/sysconfig/kafka'
}
property :jmx_port, [Integer, String], default: 9999
property :jmx_opts, String, default: '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false'
property :heap_opts, String, default: '-Xmx1G -Xms1G'
property :generic_opts, [String, nil], default: nil
property :gc_log_opts, [String, nil], default: nil
property :log4j_opts, [String, nil], default: lazy { "-Dlog4j.configuration=file:#{::File.join(config_dir, 'log4j.properties')}" }
property :jvm_performance_opts, [String, nil], default: '-server -Djava.awt.headless=true'
