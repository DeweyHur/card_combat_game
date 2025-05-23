String mapEquipmentSlotToPanelSlot(String slot, String type, String name) {
  switch (slot) {
    case 'head':
      return 'Head';
    case 'armor':
      if (name.contains('Pants')) return 'Pants';
      if (name.contains('Helmet') || name.contains('Cap')) return 'Head';
      return 'Chest';
    case 'pants':
      return 'Pants';
    case 'shoes':
      return 'Shoes';
    case 'belt':
      return 'Belt';
    case 'weapon':
      return 'Weapon';
    case 'offhand':
      return 'Offhand';
    case 'accessory1':
      return 'Accessory 1';
    case 'accessory2':
      return 'Accessory 2';
    case 'accessory':
      return 'Accessory 1';
    default:
      return slot;
  }
}
