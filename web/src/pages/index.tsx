import React, { useState, useEffect } from "react";
import {
  Card,
  Tabs,
  Row,
  Col,
  Typography,
  Avatar,
  Button,
  Space,
  Divider,
  Spin,
  Tag,
} from "antd";
import {
  UserOutlined,
  EnvironmentOutlined,
  TeamOutlined,
  EyeOutlined,
} from "@ant-design/icons";
import { useAPIGetVenues } from "@/hook/api/venue/useAPIGetVenues";
import { useAPIGetCreatorsByUserId } from "@/hook/api/creator/useAPIGetCreatorsByUserId";
import { Venue, Creator, User, CreatorEvent } from "@/type";
import PageLayout from "@/components/common/PageLayout";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { useRouter } from "next/router";
import CreatorModal from "@/components/Modal/CreatorModal";
import VenueModal from "@/components/Modal/VenueModal";
import { useAPIGetCreatorEventsByUserId } from "@/hook/api/event/useAPIGetCreatorEventsByUserId";

const { Title, Text } = Typography;
const { TabPane } = Tabs;

const MyPage: React.FC = () => {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("overview");
  const [user, setUser] = useState<User | undefined>(undefined);
  const {
    data: venues,
    refetch: refetchVenues,
    isLoading: venuesLoading,
  } = useAPIGetVenues(user?.id);
  const { mutate: mutateAuthenticate } = useAPIAuthenticate({
    onSuccess: (user) => {
      setUser(user);
    },
  });
  const {
    data: creators,
    refetch: refetchCreators,
    isLoading: creatorsLoading,
  } = useAPIGetCreatorsByUserId(user?.id);
  useEffect(() => {
    mutateAuthenticate();
  }, []);
  useEffect(() => {
    refetchVenues();
    refetchCreators();
  }, [user]);
  const {
    data: requests,
    refetch: refetchRequests,
    isLoading: requestsLoading,
  } = useAPIGetCreatorEventsByUserId(user?.id);
  const [creatorModalVisible, setCreatorModalVisible] = useState(false);
  const [venueModalVisible, setVenueModalVisible] = useState(false);

  const renderOverviewTab = () => (
    <Row gutter={[24, 24]}>
      <Col xs={24} lg={12}>
        <Card
          title="会場一覧"
          size="default"
          extra={
            <Button type="primary" onClick={() => setVenueModalVisible(true)}>
              + 登録
            </Button>
          }
        >
          {venuesLoading ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <Spin />
            </div>
          ) : venues?.length === 0 ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <EnvironmentOutlined
                style={{ fontSize: "48px", color: "#ccc" }}
              />
              <div style={{ marginTop: "16px" }}>
                <Text type="secondary">会場が見つかりません</Text>
              </div>
            </div>
          ) : (
            <Space direction="vertical" size="small" style={{ width: "100%" }}>
              {venues?.map((venue: Venue) => (
                <Card key={venue.id} size="small" hoverable>
                  <div style={{ display: "flex", alignItems: "center" }}>
                    {venue.imageUrl ? (
                      <Avatar size={40} src={venue.imageUrl} />
                    ) : (
                      <Avatar size={40} icon={<EnvironmentOutlined />} />
                    )}
                    <div style={{ marginLeft: "12px", flex: 1 }}>
                      <Text strong>{venue.name}</Text>
                      <br />
                      <Text type="secondary" style={{ fontSize: "12px" }}>
                        {venue.address}
                      </Text>
                    </div>
                    <Button
                      size="small"
                      icon={<EyeOutlined />}
                      onClick={() => router.push(`/venues/${venue.id}`)}
                    >
                      詳細
                    </Button>
                  </div>
                </Card>
              ))}
              {venues && venues.length > 5 && (
                <Button type="link" style={{ width: "100%" }}>
                  すべて表示 ({venues.length}件)
                </Button>
              )}
            </Space>
          )}
        </Card>
      </Col>
      <Col xs={24} lg={12}>
        <Card
          title="クリエイター一覧"
          size="default"
          extra={
            <Button type="primary" onClick={() => setCreatorModalVisible(true)}>
              + 登録
            </Button>
          }
        >
          {creatorsLoading ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <Spin />
            </div>
          ) : creators?.length === 0 ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <TeamOutlined style={{ fontSize: "48px", color: "#ccc" }} />
              <div style={{ marginTop: "16px" }}>
                <Text type="secondary">クリエイターが見つかりません</Text>
              </div>
            </div>
          ) : (
            <Space direction="vertical" size="small" style={{ width: "100%" }}>
              {creators?.map((creator: Creator) => (
                <Card key={creator.id} size="small" hoverable>
                  <div style={{ display: "flex", alignItems: "center" }}>
                    {creator.imageUrl ? (
                      <Avatar size={40} src={creator.imageUrl} />
                    ) : (
                      <Avatar size={40} icon={<UserOutlined />} />
                    )}
                    <div style={{ marginLeft: "12px", flex: 1 }}>
                      <Text strong>{creator.name}</Text>
                      <br />
                      <Text type="secondary" style={{ fontSize: "12px" }}>
                        {creator.description || "説明なし"}
                      </Text>
                    </div>
                    <Button
                      size="small"
                      icon={<EyeOutlined />}
                      onClick={() => router.push(`/creators/${creator.id}`)}
                    >
                      詳細
                    </Button>
                  </div>
                </Card>
              ))}
              {creators && creators.length > 5 && (
                <Button type="link" style={{ width: "100%" }}>
                  すべて表示 ({creators.length}件)
                </Button>
              )}
            </Space>
          )}
        </Card>
      </Col>
    </Row>
  );

  const renderVenuesTab = () => (
    <Row gutter={[24, 24]}>
      <Col xs={24} lg={12}>
        {venuesLoading ? (
          <div style={{ textAlign: "center", padding: "20px" }}>
            <Spin />
          </div>
        ) : venues?.length === 0 ? (
          <div style={{ textAlign: "center", padding: "20px" }}>
            <EnvironmentOutlined style={{ fontSize: "48px", color: "#ccc" }} />
            <div style={{ marginTop: "16px" }}>
              <Text type="secondary">会場が見つかりません</Text>
            </div>
          </div>
        ) : (
          <Space direction="vertical" size="small" style={{ width: "100%" }}>
            {venues?.map((venue: Venue) => (
              <Card key={venue.id} size="small" hoverable>
                <div style={{ display: "flex", alignItems: "center" }}>
                  {venue.imageUrl ? (
                    <Avatar size={40} src={venue.imageUrl} />
                  ) : (
                    <Avatar size={40} icon={<EnvironmentOutlined />} />
                  )}
                  <div style={{ marginLeft: "12px", flex: 1 }}>
                    <Text strong>{venue.name}</Text>
                    <br />
                    <Text type="secondary" style={{ fontSize: "12px" }}>
                      {venue.address}
                    </Text>
                  </div>
                  <Button
                    size="small"
                    icon={<EyeOutlined />}
                    onClick={() => router.push(`/venues/${venue.id}`)}
                  >
                    詳細
                  </Button>
                </div>
              </Card>
            ))}
            {venues && venues.length > 5 && (
              <Button type="link" style={{ width: "100%" }}>
                すべて表示 ({venues.length}件)
              </Button>
            )}
          </Space>
        )}
      </Col>
    </Row>
  );

  const renderCreatorsTab = () => (
    <Row gutter={[24, 24]}>
      <Col xs={24} lg={12}>
        <Card title="クリエイター一覧" size="small">
          {creatorsLoading ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <Spin />
            </div>
          ) : creators?.length === 0 ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <TeamOutlined style={{ fontSize: "48px", color: "#ccc" }} />
              <div style={{ marginTop: "16px" }}>
                <Text type="secondary">クリエイターが見つかりません</Text>
              </div>
            </div>
          ) : (
            <Space direction="vertical" size="small" style={{ width: "100%" }}>
              {creators?.map((creator: Creator) => (
                <Card key={creator.id} size="small" hoverable>
                  <div style={{ display: "flex", alignItems: "center" }}>
                    {creator.imageUrl ? (
                      <Avatar size={40} src={creator.imageUrl} />
                    ) : (
                      <Avatar size={40} icon={<UserOutlined />} />
                    )}
                    <div style={{ marginLeft: "12px", flex: 1 }}>
                      <Text strong>{creator.name}</Text>
                      <br />
                      <Text type="secondary" style={{ fontSize: "12px" }}>
                        {creator.description || "説明なし"}
                      </Text>
                    </div>
                    <Button
                      size="small"
                      icon={<EyeOutlined />}
                      onClick={() => router.push(`/creators/${creator.id}`)}
                    >
                      詳細
                    </Button>
                  </div>
                </Card>
              ))}
              {creators && creators.length > 5 && (
                <Button type="link" style={{ width: "100%" }}>
                  すべて表示 ({creators.length}件)
                </Button>
              )}
            </Space>
          )}
        </Card>
      </Col>
      <Col xs={24} lg={12}>
        <Card title="参加依頼一覧" size="small">
          {requestsLoading ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <Spin />
            </div>
          ) : requests?.length === 0 ? (
            <div style={{ textAlign: "center", padding: "20px" }}>
              <TeamOutlined style={{ fontSize: "48px", color: "#ccc" }} />
              <div style={{ marginTop: "16px" }}>
                <Text type="secondary">参加依頼が見つかりません</Text>
              </div>
            </div>
          ) : (
            <Space direction="vertical" size="small" style={{ width: "100%" }}>
              {requests
                ?.filter(
                  (request: CreatorEvent) => request.acceptFlag === false
                )
                .map((request: CreatorEvent) => (
                  <Card
                    key={request.id}
                    size="small"
                    hoverable
                    onClick={() => router.push(`/events/${request.event.id}`)}
                  >
                    <div
                      style={{
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "space-between",
                      }}
                    >
                      <div style={{ marginRight: "12px" }}>
                        <Text strong>{request.event.title}</Text>
                      </div>
                      <div style={{ marginRight: "12px" }}>
                        <Tag icon={<TeamOutlined />} color="green">
                          {request.creator.name}
                        </Tag>
                      </div>
                    </div>
                  </Card>
                ))}
              {requests && requests.length > 5 && (
                <Button type="link" style={{ width: "100%" }}>
                  すべて表示 ({requests.length}件)
                </Button>
              )}
            </Space>
          )}
        </Card>
      </Col>
    </Row>
  );

  return (
    <PageLayout>
      <div style={{ padding: "24px" }}>
        <Title level={2}>マイページ</Title>
        <Divider />

        <Tabs activeKey={activeTab} onChange={setActiveTab}>
          <TabPane tab="概要" key="overview">
            {renderOverviewTab()}
          </TabPane>
          <TabPane tab="会場" key="venues">
            {renderVenuesTab()}
          </TabPane>
          <TabPane tab="クリエイター" key="creators">
            {renderCreatorsTab()}
          </TabPane>
        </Tabs>
      </div>
      <CreatorModal
        visible={creatorModalVisible}
        onCancel={() => setCreatorModalVisible(false)}
        onSuccess={() => {
          refetchCreators();
          setCreatorModalVisible(false);
        }}
      />
      <VenueModal
        visible={venueModalVisible}
        onCancel={() => setVenueModalVisible(false)}
        onSuccess={() => {
          refetchVenues();
          setVenueModalVisible(false);
        }}
      />
    </PageLayout>
  );
};

export default MyPage;
