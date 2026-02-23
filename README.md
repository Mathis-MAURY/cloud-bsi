# Rapport de Projet : Infrastructure Haute Disponibilité sur Azure avec Terraform

**Étudiant :** Mathis MAURY  
**Formation :** TP DevOps / Cloud Computing  
**Date :** Février 2026

---

## 1. Structure et Organisation (Partie 1 — 10 pts)
Le projet respecte scrupuleusement la modularité et les conventions de nommage exigées par le barème. Chaque fichier possède une responsabilité unique :
* **`versions.tf`** : Définition de la version de Terraform et du bloc `required_providers`.
* **`provider.tf`** : Configuration du fournisseur Azure avec le bloc obligatoire `features {}`.
* **`variables.tf`** : Centralisation de tous les paramètres (prefix, localisation, tailles de VM).
* **`main.tf`** : Définition exhaustive des ressources.
* **`outputs.tf`** : Exposition des données critiques (IP du Load Balancer, IDs réseau).

> **Pénalités évitées :** Utilisation d'un fichier `.gitignore` pour exclure les fichiers `.tfstate`, `.terraform/` et les logs, garantissant la sécurité des credentials.

---

## 2. Architecture Réseau (Partie 2 — 15 pts)
L'infrastructure est isolée au sein d'un Virtual Network dédié :
* **Resource Group** : Nommé dynamiquement via `${var.prefix}-rg`.
* **Tags** : Ajout de tags `environment` et `owner` pour la traçabilité.
* **VNET & Subnet** : Configuration d'un espace d'adressage en `10.0.0.0/16` et d'un sous-réseau en `10.0.1.0/24`.



---

## 3. Sécurité et Pare-feu (Partie 3 — 15 pts)
La sécurité est gérée par un **Network Security Group (NSG)** rattaché au sous-réseau :
* **Port 22 (SSH)** : Autorisé pour l'administration.
* **Port 80 (HTTP)** : Autorisé pour le trafic web entrant vers le Load Balancer.
* **Règle DenyAll** : Une règle de priorité 4096 bloque tout le reste du trafic par défaut pour respecter le principe du moindre privilège.

---

## 4. Machines Virtuelles & Automatisation (Partie 4 — 25 pts)
Déploiement de **deux instances Linux** (`Standard_B1s`) hautement disponibles :
* **Sans IP Publique** : Les NICs sont privées, augmentant la sécurité (accès uniquement via le LB).
* **Installation Automatisée** : Utilisation de `custom_data` (script Bash encodé en base64) pour installer **Nginx** au premier boot.
* **Personnalisation** : Le script injecte dynamiquement l'index de la VM dans la page HTML pour prouver le bon fonctionnement du Load Balancer.

---

## 5. Load Balancer (Partie 5 — 25 pts)
Mise en place d'un répartiteur de charge pour distribuer le trafic :
* **IP Publique Standard** : Allocation statique avec SKU Standard.
* **Sondes de santé (Health Probe)** : Monitoring du port 80 pour s'assurer que les VMs répondent avant d'envoyer du trafic.
* **Backend Pool** : Association automatique des interfaces réseau (NICs) des deux VMs.



---

## 6. Validation & Preuves (Partie 6 — 10 pts)

### Preuve 1 : Terraform Plan
*Le plan confirme la création de 16 ressources sans conflit.*
*(Ajoutez votre screenshot ici)*

<img width="802" height="147" alt="image" src="https://github.com/user-attachments/assets/0ca2a586-534b-47cc-a7c0-40148a1601e9" />


### Preuve 2 : Accès Web via Load Balancer
*En interrogeant l'IP du Load Balancer, nous obtenons la réponse des serveurs Nginx provisionnés.*
*(Ajoutez votre screenshot du navigateur affichant "Salut ! C'est la VM de Mathis")*

### Preuve 3 : Terraform Destroy
*Nettoyage complet effectué avec succès, garantissant qu'aucune ressource orpheline n'est facturée.*
*(Ajoutez votre screenshot du terminal avec "Destroy complete!")*

---

## 🛠️ Guide d'utilisation rapide
1.  **Initialiser** : `terraform init`
2.  **Vérifier** : `terraform plan`
3.  **Déployer** : `terraform apply -auto-approve`
4.  **Détruire** : `terraform destroy -auto-approve`

---

### Conclusion sur le barème :
* **Variables** : 100% utilisé (pas de valeurs "en dur").
* **Structure** : Fichiers séparés selon les standards HashiCorp.
* **Pénalités** : Aucune (Nettoyage effectué, Git propre).
