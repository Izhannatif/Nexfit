import React, { useContext, useEffect, useState } from 'react'
import AuthContext from '../Context/AuthContext'
import { useNavigate, Link } from 'react-router-dom'
import axios from 'axios'
import { Table } from 'flowbite-react';
import Sidebar from '../Components/Sidebar'

const DisplayUsers = () => {
  let { user } = useContext(AuthContext)

    useEffect(() => {
        console.log(user);
        getUserData(user.user_id);
    }, [])

    const [userData, setUserData] = useState([])
    const [gymUsers, setGymUsers] = useState([])

    const navigate = useNavigate()
   
   
    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        setUserData(response1.data)
        let response2 = await axios.get(`http://192.168.1.13:8001/api/gym-users/${response1.data.gym}/`)
        console.log(response2.data)
        setGymUsers(response2.data)
    }

  return (
    <section className='w-screen p-10'>
      <p className='uppercase text-2xl font-extrabold'>ALL {userData.gym_name} USERS</p>
    <div className="overflow-x-auto">
      <Table hoverable className='text-center'>
        <Table.Head>
          <Table.HeadCell className='py-5'>ID</Table.HeadCell>
          <Table.HeadCell className='py-5'>Username</Table.HeadCell>
          <Table.HeadCell className='py-5'>Email</Table.HeadCell>
          <Table.HeadCell className='py-5'>Name</Table.HeadCell>
          <Table.HeadCell className='py-5'>Contact</Table.HeadCell>
          <Table.HeadCell className='py-5'>Gym</Table.HeadCell>
          <Table.HeadCell className='py-5'>Trainer</Table.HeadCell>
          <Table.HeadCell className='py-5'>Membership Status</Table.HeadCell>
          <Table.HeadCell className='py-5'>No. of Tokens</Table.HeadCell>
          
          <Table.HeadCell>
            <span className="sr-only">Edit</span>
          </Table.HeadCell>
        </Table.Head>
        <Table.Body className="divide-y">
          {
            gymUsers && gymUsers.map((user,i)=>(

          <Table.Row key={i} className="bg-white dark:border-gray-700 dark:bg-gray-800">
            <Table.Cell className=" py-5whitespace-nowrap font-medium text-gray-900 dark:text-white">
              {user.id}
            </Table.Cell>
            <Table.Cell className=''>{user.username}</Table.Cell>
            <Table.Cell className=''>{user.email}</Table.Cell>
            <Table.Cell className=''>{user.first_name} {user.last_name}</Table.Cell>
            <Table.Cell className=''>{user.contact}</Table.Cell>
            <Table.Cell className=''>{user.gym_name}</Table.Cell>
            <Table.Cell className=''>{user.trainerSelected ? 'True' : 'False'}</Table.Cell>
            <Table.Cell className=''>Active</Table.Cell>
            <Table.Cell className=''>{user.number_of_tokens}</Table.Cell>
          </Table.Row>
            ))
          }
         
        </Table.Body>
      </Table>
    </div>
    </section>
  );

}

export default DisplayUsers