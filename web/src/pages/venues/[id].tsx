import React, { useState, useEffect } from "react";
import { useRouter } from "next/router";
import {
  Card,
  Spin,
  Alert,
  Typography,
  Button,
  Row,
  Col,
  Divider,
  Space,
} from "antd";
import {
  EnvironmentOutlined,
  UserOutlined,
  CalendarOutlined,
  ArrowLeftOutlined,
  EditOutlined,
  DeleteOutlined,
} from "@ant-design/icons";
import { useAPIGetVenueById } from "@/hook/api/venue/useAPIGetVenueById";
import PageLayout from "@/components/common/PageLayout";
import VenueModal from "@/components/Modal/VenueModal";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { User } from "@/type";
import { useAPIDeleteVenue } from "@/hook/api/venue/useAPIDeleteVenue";

const { Title, Text, Paragraph } = Typography;

const VenueDetailPage: React.FC = () => {
  const router = useRouter();
  const { id } = router.query;
  const {
    data: venue,
    isLoading,
    error,
    refetch,
  } = useAPIGetVenueById(id as string);
  const [modalVisible, setModalVisible] = useState(false);
  const [user, setUser] = useState<User | undefined>(undefined);
  const { mutate: mutateAuthenticate } = useAPIAuthenticate({
    onSuccess: (user) => {
      setUser(user);
    },
  });
  const { mutate: mutateDeleteVenue } = useAPIDeleteVenue({
    onSuccess: () => {
      refetch();
    },
  });
  useEffect(() => {
    mutateAuthenticate();
  }, []);

  if (isLoading) {
    return (
      <PageLayout>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "50vh",
          }}
        >
          <Spin size="large" />
        </div>
      </PageLayout>
    );
  }

  if (error) {
    return (
      <PageLayout>
        <Alert
          message="エラー"
          description={error.message}
          type="error"
          showIcon
          action={
            <Button size="small" danger onClick={() => refetch()}>
              再試行
            </Button>
          }
        />
      </PageLayout>
    );
  }

  if (!venue) {
    return (
      <PageLayout>
        <Alert
          message="会場が見つかりません"
          description="指定された会場が存在しないか、削除された可能性があります。"
          type="warning"
          showIcon
        />
      </PageLayout>
    );
  }

  return (
    <PageLayout>
      <div style={{ padding: "24px" }}>
        {/* ヘッダー部分 */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "24px",
          }}
        >
          <Button
            icon={<ArrowLeftOutlined />}
            onClick={() => router.back()}
            style={{ marginRight: "16px" }}
          >
            戻る
          </Button>
          <Title level={2} style={{ margin: 0, flex: 1 }}>
            {venue.name}
          </Title>
          {venue.user.id === user?.id && (
            <div style={{ display: "flex", gap: "8px" }}>
              <Button
                type="primary"
                icon={<EditOutlined />}
                onClick={() => setModalVisible(true)}
              >
                編集
              </Button>
              <Button
                type="primary"
                danger
                icon={<DeleteOutlined />}
                onClick={() => mutateDeleteVenue(venue.id)}
              >
                削除
              </Button>
            </div>
          )}
        </div>

        <Row gutter={[24, 24]}>
          {/* 画像とメイン情報 */}
          <Col xs={24} lg={16}>
            <Card>
              {venue.imageUrl ? (
                <img
                  alt={venue.name}
                  src={venue.imageUrl}
                  style={{
                    width: "100%",
                    height: "400px",
                    objectFit: "cover",
                    borderRadius: "8px",
                    marginBottom: "16px",
                  }}
                />
              ) : (
                <div
                  style={{
                    height: "400px",
                    backgroundColor: "#f5f5f5",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    borderRadius: "8px",
                    marginBottom: "16px",
                  }}
                >
                  <EnvironmentOutlined
                    style={{ fontSize: "64px", color: "#ccc" }}
                  />
                </div>
              )}

              <div>
                <Title level={3}>基本情報</Title>
                <Space
                  direction="vertical"
                  size="middle"
                  style={{ width: "100%" }}
                >
                  <div>
                    <EnvironmentOutlined style={{ marginRight: "8px" }} />
                    <Text strong>住所:</Text>
                    <Text style={{ marginLeft: "8px" }}>{venue.address}</Text>
                  </div>

                  {venue.description && (
                    <div>
                      <Text strong>説明:</Text>
                      <Paragraph style={{ marginTop: "8px", marginBottom: 0 }}>
                        {venue.description}
                      </Paragraph>
                    </div>
                  )}

                  <Divider />

                  <Row gutter={[16, 16]}>
                    {venue.capacity && (
                      <Col xs={24} sm={12}>
                        <Card size="small">
                          <div style={{ textAlign: "center" }}>
                            <UserOutlined
                              style={{
                                fontSize: "24px",
                                color: "#1890ff",
                                marginBottom: "8px",
                              }}
                            />
                            <div>
                              <Text strong>定員</Text>
                              <div>
                                <Text
                                  style={{
                                    fontSize: "20px",
                                    fontWeight: "bold",
                                  }}
                                >
                                  {venue.capacity}人
                                </Text>
                              </div>
                            </div>
                          </div>
                        </Card>
                      </Col>
                    )}
                    {venue.availableTime && (
                      <Col xs={24} sm={12}>
                        <Card size="small">
                          <div style={{ textAlign: "center" }}>
                            <CalendarOutlined
                              style={{
                                fontSize: "24px",
                                color: "#52c41a",
                                marginBottom: "8px",
                              }}
                            />
                            <div>
                              <Text strong>利用可能時間</Text>
                              <div>
                                <Text
                                  style={{
                                    fontSize: "20px",
                                    fontWeight: "bold",
                                  }}
                                >
                                  {venue.availableTime}
                                </Text>
                              </div>
                            </div>
                          </div>
                        </Card>
                      </Col>
                    )}
                  </Row>
                </Space>
              </div>
            </Card>
          </Col>

          {/* サイドバー情報 */}
          <Col xs={24} lg={8}>
            <Space direction="vertical" size="middle" style={{ width: "100%" }}>
              {/* 基本情報カード */}
              <Card title="会場情報" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text type="secondary">会場名:</Text>
                    <Text style={{ marginLeft: "8px" }}>{venue.name}</Text>
                  </div>
                  <div>
                    <Text type="secondary">TEL:</Text>
                    <Text style={{ marginLeft: "8px" }}>{venue.tel}</Text>
                  </div>
                  <div>
                    <Text type="secondary">設備情報:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {venue.facilities}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">登録日:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date(venue.createdAt).toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                  <div>
                    <Text type="secondary">最終更新:</Text>
                    <Text style={{ marginLeft: "8px" }}>
                      {new Date(venue.updatedAt).toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                </Space>
              </Card>
              {/* アクションボタン */}
              <Card title="アクション" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <Button type="primary" block icon={<CalendarOutlined />}>
                    予約する
                  </Button>
                  <Button block icon={<EditOutlined />}>
                    編集する
                  </Button>
                  <Button danger block>
                    削除する
                  </Button>
                </Space>
              </Card>
            </Space>
          </Col>
        </Row>

        <VenueModal
          visible={modalVisible}
          onCancel={() => setModalVisible(false)}
          onSuccess={() => {
            refetch();
            setModalVisible(false);
          }}
          venue={venue}
        />
      </div>
    </PageLayout>
  );
};

export default VenueDetailPage;
