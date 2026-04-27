import React, { useContext, useEffect, useState } from 'react'
import AuthContext from '../Context/AuthContext'
import { useNavigate, Link } from 'react-router-dom'
import axios from 'axios'
import Sidebar from '../Components/Sidebar'
import {
    Card,
    CardHeader,
    Input,
    Typography,
    Button,
    CardBody,
    Chip,
    CardFooter,
    Tabs,
    TabsHeader,
    Tab,
    Avatar,
    IconButton,
    Tooltip,
} from "@material-tailwind/react";

import { FaPlus } from "react-icons/fa6";

const AllEquipments = () => {
    let { user } = useContext(AuthContext)

    const [userData, setUserData] = useState([])
    const [gymEquipments, setGymEquipments] = useState([])

    const navigate = useNavigate()

    useEffect(() => {
        console.log(user);
        getUserData(user.user_id);
    }, [])

    const getUserData = async (id) => {
        let response1 = await axios.get(`http://192.168.1.13:8001/api/admin/${id}/`)
        console.log(response1.data)
        setUserData(response1.data)
        let response2 = await axios.get(`http://192.168.1.13:8001/api/${response1.data.gym}/all-equipments/`)
        console.log(response2.data)
        setGymEquipments(response2.data.equipment_list)
    }
    const TABLE_HEAD = ["ID", "Name", "Category", "Description", "Quantity"];

    return (
        <Sidebar pageName="Equipments">
        <div className="mb-8 flex items-center justify-between gap-8">
            <div className="flex shrink-0 flex-col gap-2 sm:flex-row">
                <Link to={'/add-equipment'} className="btn-new"><FaPlus className="mr-2"/> New Equipment</Link>
            </div>
        </div>

        <div className="bg-main p-3 rounded-xl">
            <table className="w-full table-auto text-left">
                    <thead>
                        <tr>
                            {TABLE_HEAD.map((head) => (
                                <th key={head} className="bg-black border-y border-y-gray-900 p-4">
                                    {head}
                                </th>
                            ))}
                        </tr>
                    </thead>
                    <tbody>
                        {gymEquipments.map(
                            (equipment, index) => {
                                const isLast = index === gymEquipments.length - 1;
                                const classes = isLast
                                    ? "p-4"
                                    : "p-4 border-b border-gray-900";

                                return (
                                    <tr key={index}>
                                        <td className={classes}>
                                            {index + 1}
                                        </td>
                                        <td className={classes}>
                                            {equipment.name}
                                        </td>
                                        <td className={classes}>
                                            {equipment.category}
                                        </td>
                                        <td className={classes}>
                                            {equipment.description}
                                        </td>
                                        <td className={classes}>
                                            {equipment.quantity}
                                        </td>
                                    </tr>
                                );
                            },
                        )}
                    </tbody>
            </table>
            </div>
        </Sidebar>
    )
}

export default AllEquipments