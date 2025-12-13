from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier

iris = load_iris()
X, y = iris.data, iris.target

clf = RandomForestClassifier()
clf.fit(X, y)
target_names = iris.target_names