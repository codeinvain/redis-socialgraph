class Redis
  class Socialgraph
    class Client
      include Singleton
      def initialize
        @redis= Socialgraph.config.redis
      end


      def key(user_id)
        "redis_friends:#{ user_id }"
      end

      # Transactionally adds 1 or more friends to a user
      def sync_friend_ids(user_id, friend_ids)
        @redis.multi do
          @redis.del key(user_id)
          @redis.sadd key(user_id), friend_ids
        end
      end

      # Transactionally and reciprocally add a friendship
      def add_friend(user_id, friend_id)
        @redis.multi do
          @redis.sadd key(user_id), friend_id
          @redis.sadd key(friend_id), user_id
        end
      end

      # Transactionally and reciprocally remove a friendship
      def remove_friend(user_id, friend_id)
        @redis.multi do
          @redis.srem key(user_id), friend_id
          @redis.srem key(friend_id), user_id
        end
      end

      # For the given user id returns an Array of friend ids
      def friend_ids(user_id)
        @redis.smembers(key(user_id)).map(&:to_i)
      end

      def friends_of_friends_ids(user_id)
        keys = ([user_id] + friend_ids(user_id)).map { |id| key(id) }
        @redis.sunion(keys).map(&:to_i) - [user_id]
      end

      # Returns an Array representing the mutual friends between two users
      def mutual_friends(a, b)
        @redis.sinter(key(a), key(b)).map(&:to_i)
      end

      # For the given user id returns a Hash where keys are the provided friend 
      # ids and values are the mutual friends between the key and user.
      def multiple_mutual_friends(user_id, friend_ids)
        friend_ids.inject({}) do |acc, friend_id|
          acc.merge friend_id => mutual_friends(user_id, friend_id)
        end
      end

      # For two user ids return the distance where:
      # -1 = unknown
      # 0 = me
      # 1 = friend
      # 2 = friend of friend
      def distance(user_id,friend_id)
        value = -1
        if (user_id==friend_id)
          value = 0
        elsif @redis.sismember(key(user_id),friend_id)
          value = 1
        elsif friends_of_friends_ids(user_id).include?(friend_id)
          value = 2
        end
        value
      end


    end
  end
end
