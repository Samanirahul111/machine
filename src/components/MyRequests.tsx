import { useState, useEffect } from 'react';
import { Plus, Calendar, AlertTriangle, Clock, Wrench } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { MaintenanceRequest } from '../types';

interface MyRequestsProps {
  onNewRequest: () => void;
}

export default function MyRequests({ onNewRequest }: MyRequestsProps) {
  const [requests, setRequests] = useState<MaintenanceRequest[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRequests();
  }, []);

  const loadRequests = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from('maintenance_requests')
      .select(`
        *,
        equipment (
          id,
          name,
          equipment_categories (id, name),
          maintenance_teams (id, name)
        )
      `)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error loading requests:', error);
      setLoading(false);
      return;
    }

    setRequests(data || []);
    setLoading(false);
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'bg-red-100 text-red-800 border-red-200';
      case 'medium':
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'low':
        return 'bg-green-100 text-green-800 border-green-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'new':
        return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'in_progress':
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'completed':
        return 'bg-green-100 text-green-800 border-green-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-gray-100 py-8 px-4">
      <div className="max-w-7xl mx-auto">
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-6 flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-white flex items-center gap-3">
                <Wrench className="w-8 h-8" />
                My Maintenance Requests
              </h1>
              <p className="text-blue-100 mt-2">View and track your submitted requests</p>
            </div>
            <button
              onClick={onNewRequest}
              className="bg-white text-blue-600 px-6 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-all shadow-md hover:shadow-lg flex items-center gap-2"
            >
              <Plus className="w-5 h-5" />
              New Request
            </button>
          </div>

          <div className="p-8">
            {loading ? (
              <div className="flex justify-center items-center py-12">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              </div>
            ) : requests.length === 0 ? (
              <div className="text-center py-12">
                <Wrench className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-gray-600 mb-2">No requests yet</h3>
                <p className="text-gray-500 mb-6">Create your first maintenance request to get started</p>
                <button
                  onClick={onNewRequest}
                  className="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-6 py-3 rounded-lg font-semibold hover:from-blue-700 hover:to-blue-800 transition-all inline-flex items-center gap-2"
                >
                  <Plus className="w-5 h-5" />
                  Create Request
                </button>
              </div>
            ) : (
              <div className="grid gap-6">
                {requests.map((request) => (
                  <div
                    key={request.id}
                    className="border border-gray-200 rounded-lg p-6 hover:shadow-md transition-all bg-white"
                  >
                    <div className="flex justify-between items-start mb-4">
                      <div className="flex-1">
                        <h3 className="text-xl font-bold text-gray-800 mb-2">{request.title}</h3>
                        <div className="flex items-center gap-2 text-gray-600 mb-2">
                          <Wrench className="w-4 h-4" />
                          <span className="font-medium">{request.equipment?.name || 'Unknown Equipment'}</span>
                        </div>
                        {request.equipment?.equipment_categories && (
                          <div className="text-sm text-gray-500">
                            Category: {request.equipment.equipment_categories.name}
                          </div>
                        )}
                      </div>
                      <div className="flex gap-2">
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getStatusColor(request.status)}`}>
                          {request.status.replace('_', ' ').toUpperCase()}
                        </span>
                        <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getPriorityColor(request.priority)}`}>
                          {request.priority.toUpperCase()}
                        </span>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <Calendar className="w-4 h-4 text-blue-600" />
                        <span>Scheduled: {formatDate(request.scheduled_date)}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <Clock className="w-4 h-4 text-blue-600" />
                        <span>Created: {formatDate(request.created_at)}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <AlertTriangle className="w-4 h-4 text-blue-600" />
                        <span>Type: {request.request_type === 'corrective' ? 'Corrective' : 'Preventive'}</span>
                      </div>
                    </div>

                    <div className="bg-gray-50 rounded-lg p-4">
                      <p className="text-sm font-semibold text-gray-700 mb-1">Description:</p>
                      <p className="text-gray-600">{request.description}</p>
                    </div>

                    {request.equipment?.maintenance_teams && (
                      <div className="mt-4 flex items-center gap-2 text-sm text-gray-600">
                        <span className="font-semibold">Assigned Team:</span>
                        <span className="bg-blue-50 text-blue-700 px-3 py-1 rounded-full">
                          {request.equipment.maintenance_teams.name}
                        </span>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
