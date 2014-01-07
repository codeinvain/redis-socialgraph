class Redis
  class Socialgraph

    def self.key(user_id)
      "redis_friends:#{ user_id }"
    end

    # Transactionally and reciprocally adds 1 or more friends to a user
    def self.sync_friend_ids(user_id, friend_ids)
      REDIS.multi do
        REDIS.sadd key(user_id), friend_ids
        [*friend_ids].each { |friend_id| REDIS.sadd key(friend_id), user_id }
      end
    end

    # Transactionally and reciprocally add a friendship
    def self.add_friend(user_id, friend_id)
      REDIS.multi do
        REDIS.sadd key(user_id), friend_id
        REDIS.sadd key(friend_id), user_id
      end
    end

    # Transactionally and reciprocally remove a friendship
    def self.remove_friend(user_id, friend_id)
      REDIS.multi do
        REDIS.srem key(user_id), friend_id
        REDIS.srem key(friend_id), user_id
      end
    end

    # For the given user id returns an Array of friend ids
    def self.friend_ids(user_id)
      REDIS.smembers(key(user_id)).map(&:to_i)
    end

    def self.friends_of_friends_ids(user_id)
      keys = ([user_id] + friend_ids(user_id)).map { |id| key(id) }
      REDIS.sunion(keys).map(&:to_i) - [user_id]
    end

    # Returns an Array representing the mutual friends between two users
    def self.mutual_friends(a, b)
      REDIS.sinter(key(a), key(b)).map(&:to_i)
    end

    # For the given user id returns a Hash where keys are the provided friend 
    # ids and values are the mutual friends between the key and user.
    def self.multiple_mutual_friends(user_id, friend_ids)
      friend_ids.inject({}) do |acc, friend_id|
        acc.merge friend_id => mutual_friends(user_id, friend_id)
      end
    end

    # For two user ids return the distance where:
    # -1 = unknown
    # 0 = me
    # 1 = friend
    # 2 = friend of friend
    def self.distance(user_id,friend_id)
      value = -1
      if (user_id==friend_id)
        value = 0
      elsif REDIS.sismember(key(user_id),friend_id)
        value = 1
      elsif friends_of_friends_ids(user_id).include?(friend_id)
        value = 2
      end
      value
    end

  end
end
