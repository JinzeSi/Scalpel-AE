import redis
import random
import string

def random_string(length=10):
    letters = string.ascii_letters
    return ''.join(random.choice(letters) for i in range(length))

def load_data_into_redis(host='localhost', port=6379, num_keys=1000):
    r = redis.Redis(host=host, port=port, db=0)
    
    for i in range(num_keys):
        key = f"key:{i}"
        value = random_string(50)
        r.set(key, value)
        if i % 1000 == 0:
            print(f"Inserted {i} keys")
    r.set('test_GET',random_string(30))
    r.decr('test_DECR')
    r.set('test_MGET1',random_string(50))
    r.set('test_MGET2',random_string(50))
    r.set('test_MGET3',random_string(50))
    for i in range(num_keys):
        key = f"key_list:{i}"
        random_number = random.randint(15, 199)
        for j in range(random_number):
            value = random_string(50)
            r.lpush(key, value)
        if i % 1000 == 0:
            print(f"Inserted {i} keys")
        if i == 222 or i == 1 or i == 999 or i == 23 or i == 98 or i == 123:
            # for j in range(500):
            for j in range(5000): 
                value = random_string(50)
                r.lpush(key, value)
    key = "key_list:1283"
    # for j in range(500):
    for j in range(5000): 
        value = random_string(50)
        r.lpush(key, value)
    key = "key_list:9999"
    # for j in range(500):
    for j in range(5000): 
        value = random_string(50)
        r.lpush(key, value)
    key = "key_list:8765"
    # for j in range(500):
    for j in range(5000): 
        value = random_string(50)
        r.lpush(key, value)
    
    # ./redis/app/bin/redis-cli LRANGE test_LRANGE 0 99
    random_LRANGE_Num = random.randint(160, 299)
    for i in range(random_LRANGE_Num):
        r.lpush('test_LRANGE', random_string(50))
        r.lpush('test_LPOP',random_string(50))
        r.lpush('test_RPOP',random_string(50))
        value = f"value_list:{i}"
        r.lpush('test_LINSERT',value)
    # ./redis/app/bin/redis-cli SPOP test_SPOP
    for i in range(num_keys):
        key = f"key_set:{i}"
        random_number = random.randint(15, 199)
        for j in range(random_number):
            value = random_string(50)
            r.sadd(key, value)
        if i % 1000 == 0:
            print(f"Inserted {i} keys")
    # ./redis/app/bin/redis-cli SPOP test_SPOP
    random_SPOP_Num = random.randint(160, 299)
    for i in range(random_SPOP_Num):
        r.sadd('test_SPOP', random_string(50))
        value = f"value_set:{i}"
        r.sadd('test_set',value)
        
    # ./redis/app/bin/redis-cli HGET test_HGET HGET_HASH_FIELD5  
    for i in range(num_keys):
        key = f"key_hash:{i}"
        random_number = random.randint(15, 199)
        for j in range(random_number):
            field = random_string(50)
            value = random_string(50)
            r.hset(key, field, value)
        if i % 1000 == 0:
            print(f"Inserted {i} keys")
    random_HGET_Num = random.randint(160, 299)
    for i in range(random_HGET_Num):
        # HGET_HASH_FIELD5
        field = f"HGET_HASH_FIELD{i}"
        r.hset('test_HGET', field, random_string(50)) 
    print("Data loading complete.")
    
    # sorted set
    for i in range(num_keys):
        key = f"key_SortSet:{i}"
        random_number = random.randint(100, 199)
        for j in range(random_number):
            numSorce = random.randint(1, 15)
            value = random_string(50)
            # mapping = {"tmp1": 1, }
            # r.zadd("tmp", mapping)
            mapping = {value: numSorce, }
            r.zadd(key, mapping)
        if i % 1000 == 0:
            print(f"Inserted {i} keys")
    random_ZADD_Num = random.randint(160, 299)
    for i in range(random_ZADD_Num):
        value = f"sortset{i}"
        numSorce = random.randint(1, 20)
        numSorce2 = random.randint(1, 20)
        numSorce3 = random.randint(1, 20)
        mapping = {value: numSorce, }
        r.zadd('test_zadd', mapping) 
        mapping = {value: numSorce2, }
        r.zadd('test_zadd1', mapping) 
        mapping = {value: numSorce3, }
        r.zadd('test_zadd2', mapping )
    # HyperLogLog
    for i in range(num_keys):
        key = f"key_HyperLogLog:{i}"
        random_number = random.randint(100, 199)
        for j in range(random_number):
            value = random_string(50)
            r.pfadd(key, value)
        if i % 1000 == 0:
            print(f"Inserted {i} keys")
    for i in range(500):
        key = f"restaurants:{i}" 
        for j in range(10):
            # 随机纬度，范围从 -90 到 +90
            latitude = random.uniform(-85, 85)
            latitude = round(latitude, 6)
            # 随机经度，范围从 -180 到 +180
            longitude = random.uniform(-180, 180)
            longitude = round(longitude, 6)
            key2 = f"restaurant:{i}" 
            # {member: (longitude, latitude)}
            r.geoadd(key,(longitude,latitude,key2))
    r.geoadd("restaurants",(116.397128,39.916527,"restaurant1"))
    r.geoadd("restaurants",(116.397428,39.919527,"restaurant2"))
    r.geoadd("restaurants",(116.400128,39.916827,"restaurant3"))
    for i in range(500):
        # 随机纬度，范围从 -90 到 +90
        latitude = random.uniform(-85, 85)
        latitude = round(latitude, 6)
        # 随机经度，范围从 -180 到 +180
        longitude = random.uniform(-180, 180)
        longitude = round(longitude, 6)
        key2 = f"restaurant:{i}" 
        r.geoadd("restaurants",(longitude,latitude,key2))
    
if __name__ == "__main__":
    load_data_into_redis(num_keys=1000)  
