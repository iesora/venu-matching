import React, { useState } from "react";
import {
  Card,
  Row,
  Col,
  Spin,
  Alert,
  Typography,
  Avatar,
  Button,
  Tag,
} from "antd";
import {
  CalendarOutlined,
  ReloadOutlined,
  EyeOutlined,
  EnvironmentOutlined,
  TeamOutlined,
  PlusOutlined,
} from "@ant-design/icons";
import { useAPIGetEvents } from "@/hook/api/event/useAPIGetEvents";
import { Event } from "@/type";
import PageLayout from "@/components/common/PageLayout";
import { useRouter } from "next/router";
import EventModal from "@/components/Modal/EventModal";
import "@/styles/pages/Card.scss";

const { Title, Text } = Typography;

const EventListPage: React.FC = () => {
  const { data: events, isLoading, error, refetch } = useAPIGetEvents();
  const router = useRouter();
  const [eventModalVisible, setEventModalVisible] = useState(false);

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

  const formatDate = (date: Date) => {
    return new Date(date).toLocaleDateString("ja-JP", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <PageLayout>
      <div style={{ padding: "24px" }}>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "24px",
          }}
        >
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => setEventModalVisible(true)}
          >
            イベント作成
          </Button>
        </div>

        {events?.length === 0 ? (
          <Card>
            <div style={{ textAlign: "center", padding: "48px 24px" }}>
              <CalendarOutlined
                style={{
                  fontSize: "48px",
                  color: "#ccc",
                  marginBottom: "16px",
                }}
              />
              <Title level={4} type="secondary">
                イベントが見つかりません
              </Title>
              <Text type="secondary">イベントが登録されていません。</Text>
            </div>
          </Card>
        ) : (
          <Row gutter={[24, 24]}>
            {events?.map((event: Event) => (
              <Col xs={24} sm={24} md={12} lg={12} xl={12} key={event.id}>
                <Card
                  hoverable
                  cover={
                    <div style={{ padding: "32px", textAlign: "center" }}>
                      <CalendarOutlined
                        style={{
                          fontSize: "64px",
                          color: "#1890ff",
                          marginBottom: "16px",
                        }}
                      />
                      <Title level={3} style={{ margin: 0 }}>
                        {event.title}
                      </Title>
                    </div>
                  }
                  onClick={() => router.push(`/events/${event.id}`)}
                  //   actions={[
                  //     <Button
                  //       type="link"
                  //       key="detail"
                  //       icon={<EyeOutlined />}
                  //       onClick={() => router.push(`/events/${event.id}`)}
                  //       className="detail-button"
                  //       style={{
                  //         width: "100%",
                  //       }}
                  //     >
                  //       詳細を見る
                  //     </Button>,
                  //   ]}
                  style={{ height: "100%" }}
                >
                  <Card.Meta
                    description={
                      <div style={{ padding: "8px" }}>
                        <div style={{ marginBottom: "16px" }}>
                          <Text type="secondary" style={{ fontSize: "14px" }}>
                            {event.description}
                          </Text>
                        </div>

                        <div style={{ marginBottom: "12px" }}>
                          <Text strong style={{ fontSize: "15px" }}>
                            開催期間:
                          </Text>
                          <br />
                          <Text type="secondary" style={{ fontSize: "14px" }}>
                            {formatDate(event.startDate)} 〜{" "}
                            {formatDate(event.endDate)}
                          </Text>
                        </div>

                        <div style={{ marginBottom: "12px" }}>
                          <Text strong style={{ fontSize: "15px" }}>
                            会場:
                          </Text>
                          <br />
                          <Tag
                            icon={<EnvironmentOutlined />}
                            color="blue"
                            onClick={() =>
                              router.push(`/venues/${event.venue.id}`)
                            }
                            style={{ marginTop: "4px", fontSize: "13px" }}
                          >
                            {event.venue.name}
                          </Tag>
                        </div>

                        <div>
                          <Text strong style={{ fontSize: "15px" }}>
                            参加クリエイター:
                          </Text>
                          <br />
                          <div style={{ marginTop: "8px" }}>
                            {event.creatorEvents.length > 0 ? (
                              event.creatorEvents.map((creatorEvent) => (
                                <Tag
                                  key={creatorEvent.id}
                                  icon={<TeamOutlined />}
                                  color="green"
                                  onClick={() =>
                                    router.push(
                                      `/creators/${creatorEvent.creator.id}`
                                    )
                                  }
                                  style={{
                                    marginBottom: "4px",
                                    marginRight: "4px",
                                    fontSize: "12px",
                                  }}
                                >
                                  {creatorEvent.creator.name}
                                </Tag>
                              ))
                            ) : (
                              <Text
                                type="secondary"
                                style={{ fontSize: "14px" }}
                              >
                                参加者なし
                              </Text>
                            )}
                          </div>
                        </div>
                      </div>
                    }
                  />
                </Card>
              </Col>
            ))}
          </Row>
        )}
      </div>

      <EventModal
        visible={eventModalVisible}
        onCancel={() => {
          setEventModalVisible(false);
        }}
        onSuccess={() => {
          refetch();
          setEventModalVisible(false);
        }}
      />
    </PageLayout>
  );
};

export default EventListPage;
