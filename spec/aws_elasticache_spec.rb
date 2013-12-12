require "hiera/backend/aws/elasticache"

class Hiera
  module Backend
    describe Aws::ElastiCache do
      let(:elasticache) { Aws::ElastiCache.new  }

      describe "#cache_nodes_by_cache_cluster_id" do
        it "raises an exception when called without cache_cluster_id set" do
          expect do
            elasticache.cache_nodes_by_cache_cluster_id
          end.to raise_error Aws::MissingFactError
        end

        it "returns all nodes in cache cluster" do
          cluster_id = "some_cluster_id"
          cluster_info = {
            :cache_clusters => [{
              :cache_nodes => [
                { :endpoint => { :address => "1.2.3.4", :port => 1234 } },
                { :endpoint => { :address => "5.6.7.8", :port => 5678 } },
              ]
            }]
          }
          options = { :cache_cluster_id => cluster_id, :show_cache_node_info => true }

          client = double
          client.stub(:describe_cache_clusters).with(options).and_return(cluster_info)
          elasticache.stub(:client).and_return(client)

          elasticache.instance_variable_set("@scope", { "cache_cluster_id" => cluster_id })
          elasticache.cache_nodes_by_cache_cluster_id.
            should eq ["1.2.3.4:1234", "5.6.7.8:5678"]
        end
      end
    end
  end
end