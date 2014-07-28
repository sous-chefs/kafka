require 'spec_helper'

describe 'kafka::topic' do
  let(:chef_run) { ChefSpec::Runner.new(step_into: ['topic']).converge('kafka::topic') }

   it 'creates a kafka topic with default values' do
     expect(chef_run).to create_kafka_topic('test9')
   end 

   it 'updates a kafka topic to change partitions' do
     expect(chef_run).to update_kafka_topic('test10').with({partitions: 2})
   end

   it 'creates a kafka topic with non default values' do
     expect(chef_run).to create_kafka_topic('test11').with({partitions: 2 , replication: 2})
   end 
end
