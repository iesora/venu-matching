import { useRouter } from "next/router";
import { Layout, Menu, MenuProps } from "antd";
import {
  HomeOutlined,
  CalendarOutlined,
  UserOutlined,
  SettingOutlined,
  MedicineBoxOutlined,
} from "@ant-design/icons";
import { accentTextColor, themeColor } from "@/utils/colors";
import "@/styles/pages/Sidebar.scss";

const { Sider } = Layout;

const Sidebar: React.FC = () => {
  const router = useRouter();
  const currentPath = router.pathname || "/";

  const handleMenuClick: MenuProps["onClick"] = ({ key }) => {
    if (key === "logout") {
      if (confirm("ログアウトしますか？")) {
        localStorage.removeItem("userToken");
        router.reload();
      }
      return;
    }
    router.push(key);
  };

  const menuItems: MenuProps["items"] = [
    {
      key: "title",
      label: "予約管理システム",
      style: {
        fontSize: "18px",
        color: accentTextColor,
        margin: "12px 0",
        pointerEvents: "none",
        cursor: "default",
        fontWeight: 800,
      },
    },
    //{ key: "/", icon: <HomeOutlined />, label: "ダッシュボード" },
    //{ key: "/customer", icon: <UserOutlined />, label: "顧客管理" },
    { key: "/reservation", icon: <CalendarOutlined />, label: "予約管理" },
    //{ key: "/staff", icon: <UserOutlined />, label: "担当者管理" },
    //{ key: "/course", icon: <UserOutlined />, label: "コース管理" },
    { key: "/dental", icon: <MedicineBoxOutlined />, label: "歯科医院管理" },
    //{ key: "/setting", icon: <SettingOutlined />, label: "設定" },
    { key: "logout", icon: <HomeOutlined />, label: "ログアウト" },
  ];

  return (
    <Sider
      width={220}
      style={{
        display: "flex",
        flexDirection: "column",
        height: "100vh",
        position: "fixed",
        backgroundColor: themeColor,
      }}
      className="sidebar"
    >
      <div className="logo" />

      <div
        style={{
          flex: 1,
          overflowY: "auto",
          minHeight: 0,
        }}
      >
        <Menu
          mode="inline"
          selectedKeys={[currentPath]}
          onClick={handleMenuClick}
          items={menuItems}
          theme="light"
          style={{ backgroundColor: themeColor, borderRight: 0 }}
        />
      </div>
    </Sider>
  );
};

export default Sidebar;
