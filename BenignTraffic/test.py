import joblib
import bnlearn as bn

BN_MODEL_PATH = 'BenignTraffic/models/bn_model1.pkl'
GMM_MODELS_PATH = 'BenignTraffic/models/gmm_models-model1.joblib'

print("Load models")

model = bn.load(BN_MODEL_PATH)
print(type(model['model']))
model['model'].get_cpds()
df = bn.sampling(model, n=10)
