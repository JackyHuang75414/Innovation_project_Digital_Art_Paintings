-- Run this in MySQL to fix image URLs that use hotlink-protected hosts
USE digital_art_paintings;

-- Artwork 1: Everydays (replace wixstatic with Wikipedia)
UPDATE artworks SET
  image_url       = 'https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Everydays--The_First_5000_Days.jpg/500px-Everydays--The_First_5000_Days.jpg',
  image_large_url = 'https://upload.wikimedia.org/wikipedia/en/a/a7/Everydays--The_First_5000_Days.jpg'
WHERE id = 1;

-- Artwork 2: Right-click Save As (replace seadn.io with Wikipedia)
UPDATE artworks SET
  image_large_url = 'https://upload.wikimedia.org/wikipedia/commons/d/d6/Right-Click_and_Save_as_Guy.gif'
WHERE id = 2;

-- Artwork 3: Coin for the Ferryman (replace seadn.io with Wikipedia)
UPDATE artworks SET
  image_large_url = 'https://upload.wikimedia.org/wikipedia/commons/a/a8/A_Coin_for_the_Ferryman.gif'
WHERE id = 3;
