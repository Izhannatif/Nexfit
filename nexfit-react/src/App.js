import LoginPage from './Pages/LoginPage';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './index.css';
import Dashboard from './Pages/Dashboard';
import PrivateRoute from './utils/PrivateRoute'
import { AuthProvider } from './Context/AuthContext';
import AddUser from './Pages/AddUser';
import AddTrainer from './Pages/AddTrainer';
import AddEquipment from './Pages/AddEquipment';
import AddExercise from './Pages/AddExercise';
import AddTokenPlan from './Pages/AddTokenPlan';
import PlanPurchase from './Pages/PlanPurchase';
import DisplayUsers from './Pages/DisplayUsers';
import Sidebar from './Components/Sidebar';
import UsersTable from './Pages/UsersTable'
import TrainerTable from './Pages/TrainerTable';
import AllEquipments from './Pages/AllEquipments';
import AllExercises from './Pages/AllExercises';
import EditUser from './Pages/EditUser';


function App() {
  return (
    <div className="App">
      <BrowserRouter>
            {/* <PrivateRoute><Sidebar /></PrivateRoute> */}
        <Routes>
            <Route element={<LoginPage />} path='/login' />
            <Route element={<PrivateRoute><Dashboard /></PrivateRoute>} path='/' />
            <Route element={<PrivateRoute><AddUser /></PrivateRoute>} path='/add-user' />
            <Route element={<PrivateRoute><AddTrainer /></PrivateRoute>} path='/add-trainer' />
            <Route element={<PrivateRoute><AddEquipment /></PrivateRoute>} path='/add-equipment' />
            <Route element={<PrivateRoute><AddExercise /></PrivateRoute>} path='/add-exercise' />
            <Route element={<PrivateRoute><AddTokenPlan /></PrivateRoute>} path='/add-token-plan' />
            <Route element={<PrivateRoute><PlanPurchase /></PrivateRoute>} path='/plan-purchase' />
            <Route element={<PrivateRoute><DisplayUsers /></PrivateRoute>} path='/gym-users' />
            <Route element={<PrivateRoute><UsersTable /></PrivateRoute>} path='/all-users' />
            <Route element={<PrivateRoute><TrainerTable /></PrivateRoute>} path='/all-trainers' />
            <Route element={<PrivateRoute><AllEquipments /></PrivateRoute>} path='/all-equipments' />
            <Route element={<PrivateRoute><AllExercises /></PrivateRoute>} path='/all-exercises' />
            <Route element={<PrivateRoute><EditUser /></PrivateRoute>} path='/edit-user/:id' />
            

        </Routes>

      </BrowserRouter>
    </div>
  );
}

export default App;
