# PAM_auto-oscillations

Ce travail porte sur la synthèse sonore et le contrôle d'instruments virtuels à partir de modèles physiques d'instruments à auto-oscillations.

On se propose dans un premier temps de décrire de manière simplifiée le comportement de systèmes à auto-oscillations, fortement non linéaires, et de dégager les aspects communs de leur comportement. Cette étude mène naturellement à une implémentation, d'abord en temps différé, puis en temps réel, qui inclut la possibilité de faire varier certains paramètres.

La nature des modèles utilisés --- notamment leur caractère non linéaire --- fait généralement apparaître plusieurs régimes ; on se propose alors de classifier les sons obtenus en faisant varier les paramètres de contrôle, en faisant l'usage de descripteurs audio bien choisis.

Ces descripteurs sont ensuite utilisés pour partitionner l'espace des paramètres selon les régimes possibles, en faisant appel à des machines à vecteurs de support (SVM). Les cartographies obtenues sont alors utilisables dans le cadre d'un contrôle temps réel des instruments virtuels obtenus.

## Localisation des fichiers

- Les modèles temps réels se trouvent dans le dossier /Faust et /PureData.
- Les modèles d'instruments non temps réels, les descripteurs et le calcul des cartographies sont dans le dossier /Matlab
- Des exemples de synthèse audio sont dans le dossier /audio-examples

## Vidéo de démonstration

https://youtu.be/os0KTHWFuuA
