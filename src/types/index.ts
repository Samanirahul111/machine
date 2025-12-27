export interface EquipmentCategory {
  id: string;
  name: string;
  created_at: string;
}

export interface MaintenanceTeam {
  id: string;
  name: string;
  created_at: string;
}

export interface Equipment {
  id: string;
  name: string;
  category_id: string;
  team_id: string;
  created_at: string;
  equipment_categories?: EquipmentCategory;
  maintenance_teams?: MaintenanceTeam;
}

export interface MaintenanceRequest {
  id: string;
  title: string;
  equipment_id: string;
  request_type: 'corrective' | 'preventive';
  scheduled_date: string;
  priority: 'low' | 'medium' | 'high';
  description: string;
  attachment_url?: string;
  status: string;
  created_at: string;
  equipment?: Equipment;
}
