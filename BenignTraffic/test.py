import joblib

GMM_MODELS_PATH = 'BenignTraffic/models/bn_model1.joblib'
BN_MODEL_PATH = 'BenignTraffic/models/gmm_models-model1.joblib'

print("Load models")
gmm_models = joblib.load(GMM_MODELS_PATH)
bn_model = joblib.load(BN_MODEL_PATH)