'''# Base de données PostgreSQL — Site de vente d’art digital avec IA et crypto

sql
-- =====================================================
-- EXTENSIONS
-- =====================================================
'''
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;

-- =====================================================
-- TYPES ENUM
-- =====================================================

CREATE TYPE type_oeuvre AS ENUM (
    'digital',
    'photo',
    'physique'
);

CREATE TYPE type_paiement AS ENUM (
    'carte',
    'paypal',
    'crypto'
);

CREATE TYPE statut_paiement AS ENUM (
    'en_attente',
    'confirme',
    'refuse',
    'rembourse'
);

-- =====================================================
-- UTILISATEURS
-- =====================================================

CREATE TABLE utilisateurs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    nom VARCHAR(100) NOT NULL,

    email VARCHAR(255) UNIQUE NOT NULL,

    mot_de_passe TEXT NOT NULL,

    photo_profil TEXT,

    role VARCHAR(50) DEFAULT 'client',

    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ADRESSES
-- =====================================================

CREATE TABLE adresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    pays VARCHAR(100),

    ville VARCHAR(100),

    code_postal VARCHAR(20),

    adresse TEXT,

    est_principale BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- ARTISTES
-- =====================================================

CREATE TABLE artistes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    nom VARCHAR(255) NOT NULL,

    biographie TEXT,

    photo_profil TEXT,

    pays VARCHAR(100),

    instagram TEXT,

    site_web TEXT,

    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- OEUVRES
-- =====================================================

CREATE TABLE oeuvres (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    artiste_id UUID REFERENCES artistes(id) ON DELETE SET NULL,

    titre VARCHAR(255) NOT NULL,

    description TEXT,

    type type_oeuvre NOT NULL,

    prix NUMERIC(10,2) NOT NULL,

    largeur INT,

    hauteur INT,

    poids NUMERIC(10,2),

    stock INT DEFAULT 1,

    fichier_url TEXT,

    miniature_url TEXT,

    est_disponible BOOLEAN DEFAULT TRUE,

    token_id VARCHAR(255),

    contrat_blockchain TEXT,

    est_nft BOOLEAN DEFAULT FALSE,

    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CATEGORIES
-- =====================================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    nom VARCHAR(100) UNIQUE NOT NULL
);

-- =====================================================
-- RELATION OEUVRES / CATEGORIES
-- =====================================================

CREATE TABLE oeuvres_categories (
    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    categorie_id UUID REFERENCES categories(id) ON DELETE CASCADE,

    PRIMARY KEY (oeuvre_id, categorie_id)
);

-- =====================================================
-- TAGS
-- =====================================================

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    nom VARCHAR(100) UNIQUE NOT NULL
);

-- =====================================================
-- RELATION OEUVRES / TAGS
-- =====================================================

CREATE TABLE oeuvres_tags (
    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,

    PRIMARY KEY (oeuvre_id, tag_id)
);

-- =====================================================
-- MEDIAS
-- =====================================================

CREATE TABLE medias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    url TEXT NOT NULL,

    type_media VARCHAR(50),

    ordre_affichage INT DEFAULT 0
);

-- =====================================================
-- FAVORIS
-- =====================================================

CREATE TABLE favoris (
    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(utilisateur_id, oeuvre_id)
);

-- =====================================================
-- AVIS
-- =====================================================

CREATE TABLE avis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    note INT CHECK (note >= 1 AND note <= 5),

    commentaire TEXT,

    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PANIER
-- =====================================================

CREATE TABLE panier (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PANIER ITEMS
-- =====================================================

CREATE TABLE panier_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    panier_id UUID REFERENCES panier(id) ON DELETE CASCADE,

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    quantite INT DEFAULT 1
);

-- =====================================================
-- COMMANDES
-- =====================================================

CREATE TABLE commandes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE SET NULL,

    total NUMERIC(10,2) NOT NULL,

    statut VARCHAR(50) DEFAULT 'en_attente',

    adresse_livraison_id UUID REFERENCES adresses(id),

    date_commande TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- DETAILS COMMANDE
-- =====================================================

CREATE TABLE commande_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    commande_id UUID REFERENCES commandes(id) ON DELETE CASCADE,

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE SET NULL,

    quantite INT DEFAULT 1,

    prix_unitaire NUMERIC(10,2)
);

-- =====================================================
-- PAIEMENTS
-- =====================================================

CREATE TABLE paiements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    commande_id UUID REFERENCES commandes(id) ON DELETE CASCADE,

    type_paiement type_paiement NOT NULL,

    montant NUMERIC(10,2) NOT NULL,

    statut statut_paiement DEFAULT 'en_attente',

    date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CRYPTOMONNAIES
-- =====================================================

CREATE TABLE cryptomonnaies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    nom VARCHAR(100) NOT NULL,

    symbole VARCHAR(20) UNIQUE NOT NULL,

    blockchain VARCHAR(100),

    actif BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- WALLETS UTILISATEUR
-- =====================================================

CREATE TABLE wallets_utilisateur (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    adresse_wallet TEXT NOT NULL,

    cryptomonnaie_id UUID REFERENCES cryptomonnaies(id),

    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TRANSACTIONS CRYPTO
-- =====================================================

CREATE TABLE transactions_crypto (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    paiement_id UUID REFERENCES paiements(id) ON DELETE CASCADE,

    wallet_expediteur TEXT NOT NULL,

    wallet_destinataire TEXT NOT NULL,

    cryptomonnaie_id UUID REFERENCES cryptomonnaies(id),

    montant_crypto NUMERIC(30,10) NOT NULL,

    hash_transaction TEXT UNIQUE NOT NULL,

    confirmations INT DEFAULT 0,

    statut VARCHAR(50) DEFAULT 'en_attente',

    date_transaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- LICENCES OEUVRES DIGITALES
-- =====================================================

CREATE TABLE licences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    type_licence VARCHAR(100),

    date_achat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INTERACTIONS UTILISATEUR (IA)
-- =====================================================

CREATE TABLE interactions_utilisateur (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,

    oeuvre_id UUID REFERENCES oeuvres(id) ON DELETE CASCADE,

    type_interaction VARCHAR(50),

    duree_vue INT,

    date_interaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PREFERENCES UTILISATEUR (IA)
-- =====================================================

CREATE TABLE preferences_utilisateur (
    utilisateur_id UUID PRIMARY KEY REFERENCES utilisateurs(id) ON DELETE CASCADE,

    style_prefere VARCHAR(100),

    couleur_preferee VARCHAR(50),

    budget_moyen NUMERIC(10,2),

    aime_digital BOOLEAN DEFAULT TRUE,

    aime_photo BOOLEAN DEFAULT TRUE,

    aime_physique BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- EMBEDDINGS IA
-- =====================================================

CREATE TABLE embeddings_oeuvres (
    oeuvre_id UUID PRIMARY KEY REFERENCES oeuvres(id) ON DELETE CASCADE,

    embedding VECTOR(768)
);

-- =====================================================
-- INDEX POUR LES PERFORMANCES
-- =====================================================

CREATE INDEX idx_oeuvres_artiste ON oeuvres(artiste_id);
CREATE INDEX idx_oeuvres_type ON oeuvres(type);
CREATE INDEX idx_paiements_commande ON paiements(commande_id);
CREATE INDEX idx_transactions_hash ON transactions_crypto(hash_transaction);
CREATE INDEX idx_interactions_utilisateur ON interactions_utilisateur(utilisateur_id);
CREATE INDEX idx_interactions_oeuvre ON interactions_utilisateur(oeuvre_id);


'''
# Architecture finale

text
Frontend Vue.js
↓
Backend Node.js / Express
↓
PostgreSQL
↓
Service IA Python
↓
Coinbase Commerce / Blockchain API


# Technologies recommandées

| Partie             | Technologie         |
| ------------------ | ------------------- |
| Frontend           | Vue.js              |
| Backend            | Node.js + Express   |
| Base de données    | PostgreSQL          |
| ORM                | Prisma              |
| IA                 | Python + FastAPI    |
| Paiement crypto    | Coinbase Commerce   |
| Hébergement images | AWS S3 / Cloudinary |
| Authentification   | JWT                 |

# Conseils importants

* Ne jamais stocker de clé privée crypto
* Utiliser HTTPS
* Protéger les téléchargements des œuvres digitales
* Utiliser des URLs temporaires pour les fichiers
* Ajouter des sauvegardes PostgreSQL
* Utiliser des index pour les performances
* Utiliser pgvector pour les recommandations IA
'''