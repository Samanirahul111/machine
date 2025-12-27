import { useState } from 'react';
import MaintenanceRequestForm from './components/MaintenanceRequestForm';
import MyRequests from './components/MyRequests';

function App() {
  const [currentView, setCurrentView] = useState<'form' | 'requests'>('requests');

  return (
    <>
      {currentView === 'form' ? (
        <MaintenanceRequestForm onSuccess={() => setCurrentView('requests')} />
      ) : (
        <MyRequests onNewRequest={() => setCurrentView('form')} />
      )}
    </>
  );
}

export default App;
