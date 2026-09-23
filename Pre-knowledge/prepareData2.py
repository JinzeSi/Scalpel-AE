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

    
if __name__ == "__main__":
    load_data_into_redis(num_keys=300000)  
