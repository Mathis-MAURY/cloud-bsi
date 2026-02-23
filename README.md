#  Rapport de Projet : Infrastructure Haute Disponibilité sur Azure avec Terraform

**Étudiant :** Mathis MAURY  
**Date :** Février 2026  
**Sujet :** Déploiement automatisé d'un Load Balancer et de serveurs Web Nginx.

---

##  1. Structure et Provider (Partie 1)
* **`versions.tf`** : Contraintes de versions Terraform et provider.
* **`provider.tf`** : Bloc `features {}` présent.
* **`variables.tf`** : Utilisation de variables pour `location` et `prefix` avec types corrects.
* **`main.tf`** : Définition des ressources.
* **`outputs.tf`** : Exposition des IDs et IPs.

---

##  2. Réseau (Partie 2)
L'infrastructure réseau est isolée et correctement référencée :
* **Resource Group** : Nom dynamique avec tags d'identification.
* **VNET** : CIDR `10.0.0.0/16` avec référence correcte au RG.
* **Subnet** : CIDR `10.0.1.0/24` rattaché au VNET.
* **Outputs** : IDs et noms du réseau exposés via le fichier `outputs.tf`.

---

##  3. Sécurité (Partie 3) 
Mise en place d'un **Network Security Group (NSG)** rattaché au subnet :
* **Règle SSH (port 22)** : Priorité et protocole configurés.
* **Règle HTTP (port 80)** : Accès autorisé pour le trafic Web.
* **Règle Deny-all** : Priorité basse pour bloquer tout trafic non autorisé explicitement.
* **Association** : Ressource d'association NSG ↔ Subnet présente dans le code.

---

##  4. Machines Virtuelles (Partie 4)
Déploiement de **2 instances Linux** avec automatisation :
* **NICs** : Adressage IP dynamique, sans IP publique directe (sécurité renforcée).
* **Configuration** : Taille `Standard_B1s`, image Ubuntu, authentification par mot de passe.
* **Custom Data** : Utilisation de `base64encode` pour installer **Nginx** et générer une page affichant dynamiquement le nom de la VM.
* **Variable Prefix** : Nommage cohérent de toutes les ressources via `var.prefix`.

---

##  5. Load Balancer (Partie 5)
Point d'entrée unique pour la haute disponibilité :
* **IP Publique** : SKU Standard et allocation Statique.
* **Backend Pool** : Association automatique des 2 cartes réseau (NICs) des VMs.
* **Health Probe** : Monitoring HTTP sur le port 80.
* **LB Rule** : Redirection du trafic port 80 vers le pool backend.
* **Output** : Affichage de l'IP publique du Load Balancer.

---

##  6. Validation et Nettoyage (Partie 6)

### Preuves de déploiement
* **Capture `terraform plan`** : Validation de la planification des ressources.
<img width="1881" height="621" alt="image" src="https://github.com/user-attachments/assets/406b8d68-d6f0-472f-8faa-284a563b6a2b" />

* **Capture `terraform apply`** : Confirmation de la création sans erreur.
<img width="802" height="147" alt="image" src="https://github.com/user-attachments/assets/0ca2a586-534b-47cc-a7c0-40148a1601e9" />

* **Capture Accès Web** : Preuve que les deux VMs répondent via l'IP du Load Balancer.
<img width="1137" height="202" alt="image" src="https://github.com/user-attachments/assets/4e07d716-b2e1-4177-9d4e-43dc88bc1918" />

<img width="1916" height="956" alt="image" src="https://github.com/user-attachments/assets/10623999-17a2-46a1-a967-67e13c5ec661" />

<img width="1912" height="953" alt="image" src="https://github.com/user-attachments/assets/befd3d86-ee8c-4b22-a322-c0f58f0c269a" />

> **Note sur le Load Balancing** : Pour voir la **VM 0** répondre après la **VM 1**, j'ai utilisé la commande suivante dans le terminal pour contourner la persistance de session du navigateur :
> `for i in {1..6}; do curl -s http://<IP_DU_LOAD_BALANCER> | grep "VM"; done`

### Nettoyage de l'infrastructure
Conformément aux consignes obligatoires pour ne pas consommer de crédits inutilement, la commande `terraform destroy` a été exécutée.
* **Capture `terraform destroy`** : Validation de la suppression de toutes les ressources.

---

### 🛡️ Respect des contraintes techniques
* **Zéro valeur en dur** : Toutes les configurations passent par des variables.
* **Structure propre** : Code réparti sur 5 fichiers distincts.
* **Sécurité Git** : Aucun fichier `.tfstate` n'est inclus dans ce rendu.

##  Observations remarquées

Lors de la réalisation de ce projet, plusieurs points techniques majeurs ont été observés et analysés pour garantir une infrastructure professionnelle.

### 1. Automatisation et Scalabilité (IaC)
* **Évolutivité horizontale :** L'utilisation du méta-argument `count = 2` démontre la puissance de l'Infrastructure as Code (IaC). Passer à 10 ou 50 instances ne nécessiterait qu'une modification d'une seule ligne dans `variables.tf`, garantissant un déploiement rapide et sans erreur humaine.
* **Bootstrapping réussi :** Le script `custom_data` permet un "Zero-touch provisioning". L'installation de Nginx et la personnalisation de la page HTML s'effectuent sans aucune connexion manuelle en SSH, assurant que le service est opérationnel dès la fin du `terraform apply`.

### 2. Haute Disponibilité et Répartition
* **Indépendance des serveurs :** Le Load Balancer agit comme un point d'entrée unique. Grâce à la sonde de santé (**Health Probe**) sur le port 80, le trafic est intelligemment redirigé. Si une VM devenait défaillante, le service resterait disponible pour l'utilisateur final.
* **Persistance de session (Hash-based) :** On observe qu'en rafraîchissant la page dans un navigateur classique, le message reste souvent bloqué sur la même VM. Cela s'explique par l'algorithme par défaut d'Azure qui lie l'IP du client à une instance pour éviter les déconnexions de session applicative.

### 3. Sécurité et "Least Privilege"
* **Isolation des instances :** Aucune des VMs ne possède d'adresse IP publique. Cette architecture de "Back-end" pur réduit drastiquement la surface d'attaque, rendant les serveurs inaccessibles directement depuis internet, sauf via le flux contrôlé du Load Balancer.
* **Pare-feu (NSG) :** La mise en place de la règle **DenyAll** (priorité 4096) respecte le principe de sécurité maximale : tout ce qui n'est pas explicitement autorisé est interdit par défaut.



### 4. Gestion du cycle de vie des ressources
* **Idempotence :** Terraform a démontré sa capacité à comparer l'état réel (State) et la configuration souhaitée. Le message "No changes" lors d'un second `plan` confirme la stabilité de l'infrastructure.
* **Responsabilité Cloud :** L'exécution systématique du `terraform destroy` en fin de TP souligne une gestion rigoureuse des coûts (FinOps), s'assurant qu'aucune ressource n'est facturée inutilement après les tests.
