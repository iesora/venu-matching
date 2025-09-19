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
  Tag,
  Avatar,
  Dropdown,
  Menu,
} from "antd";
import {
  CalendarOutlined,
  EnvironmentOutlined,
  TeamOutlined,
  ArrowLeftOutlined,
  UserOutlined,
  ClockCircleOutlined,
  EditOutlined,
  DeleteOutlined,
  MoreOutlined,
  CheckOutlined,
  CloseOutlined,
} from "@ant-design/icons";
import { useAPIGetEventById } from "@/hook/api/event/useAPIGetEventById";
import PageLayout from "@/components/common/PageLayout";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { User, Creator, AcceptStatus } from "@/type";
import EventModal from "@/components/Modal/EventModal";
import { useAPIGetCreatorsByUserId } from "@/hook/api/creator/useAPIGetCreatorsByUserId";
import { useAPIResponseCreatorEvent } from "@/hook/api/event/useAPIResponseCreatorEvent";
import { useAPIDeleteEvent } from "@/hook/api/event/useAPIDeleteEvent";
import { notification } from "antd";
import { anBlue, anRed } from "@/utils/colors";

const { Title, Text, Paragraph } = Typography;

const EventDetailPage: React.FC = () => {
  const router = useRouter();
  const { id } = router.query;
  const {
    data: event,
    isLoading,
    error,
    refetch,
  } = useAPIGetEventById(id as string);
  const [user, setUser] = useState<User | undefined>(undefined);
  const [authUserReqestedCreators, setAuthUserReqestedCreators] = useState<
    Creator[]
  >([]);
  const [isMobile, setIsMobile] = useState(false);
  const [isBottombarOpen, setIsBottombarOpen] = useState(false);
  const { mutate: mutateAuthenticate } = useAPIAuthenticate({
    onSuccess: (user) => {
      setUser(user);
    },
  });
  //ログインユーザーのクリエイター取得
  const { data: creators } = useAPIGetCreatorsByUserId(user?.id);

  // クリエイターイベント承認用のhook
  const { mutate: mutateResponseCreatorEvent } = useAPIResponseCreatorEvent({
    onSuccess: (data) => {
      notification.success({
        message: data.message,
      });
      refetch();
    },
    onError: () => {
      notification.error({
        message: "参加依頼の回答に失敗しました",
      });
    },
  });

  const { mutate: mutateDeleteEvent } = useAPIDeleteEvent({
    onSuccess: () => {
      router.push("/events");
      notification.success({
        message: "イベントを削除しました",
      });
    },
    onError: () => {
      notification.error({
        message: "イベントを削除に失敗しました",
      });
    },
  });

  //ログインユーザーのクリエイターでこのイベントからオファーがあったクリエイターを抽出
  useEffect(() => {
    // ログインユーザーのクリエイター一覧を取得
    const authUserCreators =
      creators?.filter((creator) => creator.user.id === user?.id) || [];

    // イベントに参加しているクリエイター一覧を取得
    const eventCreators =
      event?.creatorEvents
        ?.filter(
          (creatorEvent) => creatorEvent.acceptStatus === AcceptStatus.PENDING
        )
        .map((creatorEvent) => creatorEvent.creator) || [];
    console.log("event.creatorEvents: ", event?.creatorEvents);
    console.log("eventCreators: ", eventCreators);

    // ログインユーザーのクリエイターとイベントのクリエイターで一致するものを抽出
    const matchedCreators = authUserCreators.filter((authCreator) =>
      eventCreators.some((eventCreator) => eventCreator.id === authCreator.id)
    );

    setAuthUserReqestedCreators(matchedCreators);
  }, [creators, user, event]);

  const [modalVisibleMode, setModalVisibleMode] = useState<
    "overview" | "creators" | undefined
  >(undefined);

  // レスポンシブ対応：ウィンドウ幅が 500px 以下の場合はモバイル表示
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth <= 500) {
        setIsBottombarOpen(true);
        setIsMobile(true);
      } else if (window.innerWidth <= 940) {
        setIsMobile(false);
        setIsBottombarOpen(true);
      } else {
        setIsMobile(false);
        setIsBottombarOpen(false);
      }
    };

    window.addEventListener("resize", handleResize);
    // 初回チェック
    handleResize();

    return () => {
      window.removeEventListener("resize", handleResize);
    };
  }, []);

  useEffect(() => {
    mutateAuthenticate();
  }, []);

  //イベントの開催済みかどうかのステータス
  const [scheduleStatus, setScheduleStatus] = useState<
    "today" | "past" | "future"
  >("future");
  useEffect(() => {
    if (event?.endDate) {
      const startDate = new Date(event.startDate);
      const endDate = new Date(event.endDate);
      const today = new Date();
      //今日の日付とイベント開催日の年月日を比較
      if (endDate.getFullYear() < today.getFullYear()) {
        // 終了日が今年より前
        setScheduleStatus("past");
      } else if (startDate.getFullYear() > today.getFullYear()) {
        // 開始日が今年より後
        setScheduleStatus("future");
      } else {
        // イベント期間が今年
        if (
          endDate.getFullYear() == today.getFullYear() &&
          endDate.getMonth() < today.getMonth()
        ) {
          // 終了日が今月より前
          setScheduleStatus("past");
        } else if (
          startDate.getFullYear() == today.getFullYear() &&
          startDate.getMonth() > today.getMonth()
        ) {
          // 開始日が今月より後
          setScheduleStatus("future");
        } else {
          //イベント期間が今月
          if (
            endDate.getFullYear() == today.getFullYear() &&
            endDate.getMonth() == today.getMonth() &&
            endDate.getDate() < today.getDate()
          ) {
            // 終了日が今日より前
            setScheduleStatus("past");
          } else if (
            startDate.getFullYear() == today.getFullYear() &&
            startDate.getMonth() == today.getMonth() &&
            startDate.getDate() > today.getDate()
          ) {
            // 開始日が今日より後
            setScheduleStatus("future");
          } else {
            // イベント期間が今日
            setScheduleStatus("today");
          }
        }
      }
    }
  }, [event]);

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

  if (!event) {
    return (
      <PageLayout>
        <Alert
          message="イベントが見つかりません"
          description="指定されたイベントが存在しないか、削除された可能性があります。"
          type="warning"
          showIcon
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

  const formatDateOnly = (date: Date) => {
    return new Date(date).toLocaleDateString("ja-JP", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const formatTimeOnly = (date: Date) => {
    return new Date(date).toLocaleTimeString("ja-JP", {
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <PageLayout>
      <div style={{ padding: isMobile ? "16px" : "24px" }}>
        {/* ヘッダー部分 */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: isMobile ? "16px" : "24px",
            flexDirection: isMobile ? "column" : "row",
            gap: isMobile ? "12px" : "0",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              width: isMobile ? "100%" : "auto",
            }}
          >
            <Button
              icon={<ArrowLeftOutlined />}
              onClick={() => router.back()}
              style={{ marginRight: "16px" }}
              size={isMobile ? "large" : "middle"}
            >
              {!isMobile ? "戻る" : undefined}
            </Button>
            {isMobile && (
              <Title
                level={3}
                style={{
                  margin: 0,
                  flex: 1,
                  fontSize: isMobile ? "18px" : "24px",
                }}
              >
                {event.title}
              </Title>
            )}
          </div>

          {!isMobile && (
            <Title level={2} style={{ margin: 0, flex: 1 }}>
              {event.title}
            </Title>
          )}

          {event.venue.user.id === user?.id && (
            <div
              style={{
                display: "flex",
                gap: "8px",
                width: isMobile ? "100%" : "auto",
                justifyContent: isMobile ? "flex-start" : "flex-end",
              }}
            >
              {isBottombarOpen && !isMobile ? (
                <Dropdown
                  overlay={
                    <Menu>
                      <Menu.Item
                        key="editOverview"
                        icon={<EditOutlined />}
                        onClick={() => setModalVisibleMode("overview")}
                      >
                        概要を編集
                      </Menu.Item>
                      <Menu.Item
                        key="editCreators"
                        icon={<EditOutlined />}
                        onClick={() => setModalVisibleMode("creators")}
                      >
                        クリエイターを編集
                      </Menu.Item>
                      <Menu.Item
                        key="delete"
                        icon={<DeleteOutlined />}
                        onClick={() => mutateDeleteEvent(event.id)}
                      >
                        削除
                      </Menu.Item>
                    </Menu>
                  }
                  trigger={["click"]}
                >
                  <Button icon={<MoreOutlined />} size="middle" />
                </Dropdown>
              ) : (
                <>
                  <Button
                    type="primary"
                    icon={!isMobile ? <EditOutlined /> : undefined}
                    size={isMobile ? "small" : "middle"}
                    style={{
                      backgroundColor: anBlue,
                      borderColor: anBlue,
                      fontSize: isMobile ? "14px" : "16px",
                    }}
                    onClick={() => setModalVisibleMode("overview")}
                  >
                    概要を編集
                  </Button>
                  <Button
                    size={isMobile ? "small" : "middle"}
                    type="primary"
                    icon={!isMobile ? <EditOutlined /> : undefined}
                    style={{
                      backgroundColor: anBlue,
                      borderColor: anBlue,
                      fontSize: isMobile ? "14px" : "16px",
                    }}
                    onClick={() => setModalVisibleMode("creators")}
                  >
                    クリエイターを編集
                  </Button>
                  <Button
                    type="primary"
                    danger
                    style={{
                      backgroundColor: anRed,
                      borderColor: anRed,
                      fontSize: isMobile ? "14px" : "16px",
                    }}
                    icon={!isMobile ? <DeleteOutlined /> : undefined}
                    size={isMobile ? "small" : "middle"}
                    onClick={() => mutateDeleteEvent(event.id)}
                  >
                    削除
                  </Button>
                </>
              )}
            </div>
          )}
        </div>
        {authUserReqestedCreators.length > 0 && (
          <Card
            style={{
              marginBottom: isMobile ? "16px" : "24px",
              border: "2px solid #1890ff",
              backgroundColor: "#f6ffed",
            }}
          >
            <div style={{ textAlign: "left" }}>
              <Title
                level={isMobile ? 5 : 4}
                style={{ color: "#1890ff", marginBottom: "16px" }}
              >
                {/* <CalendarOutlined style={{ marginRight: "8px" }} /> */}!
                このイベントへの参加依頼が届いています
              </Title>
              <Space
                size="large"
                direction="vertical"
                style={{ width: "100%" }}
              >
                <div
                  style={{
                    display: "flex",
                    flexDirection: "column",
                    gap: isMobile ? "12px" : "16px",
                  }}
                >
                  {/* クリエイター承認セクション */}
                  {authUserReqestedCreators.length > 0 &&
                    authUserReqestedCreators.map((creator) => (
                      <Card>
                        <div
                          style={{
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "space-between",
                            gap: isMobile ? "8px" : "16px",
                            flexDirection: isMobile ? "column" : "row",
                          }}
                        >
                          <Text
                            strong
                            style={{
                              fontSize: isMobile ? "14px" : "16px",
                              textAlign: isMobile ? "center" : "left",
                            }}
                          >
                            {creator.name}
                          </Text>
                          {!isBottombarOpen && !isMobile ? (
                            <div>
                              <Button
                                type="primary"
                                size="large"
                                style={{
                                  marginRight: "16px",
                                  height: "30px",
                                  fontSize: "16px",
                                  minWidth: "120px",
                                  backgroundColor: anBlue,
                                  borderColor: anBlue,
                                }}
                                onClick={() => {
                                  // 該当するcreatorEventのIDを取得
                                  const creatorEvent =
                                    event?.creatorEvents?.find(
                                      (ce) => ce.creator.id === creator.id
                                    );
                                  if (creatorEvent) {
                                    mutateResponseCreatorEvent({
                                      creatorEventId: creatorEvent.id,
                                      acceptStatus: AcceptStatus.ACCEPTED,
                                    });
                                  }
                                }}
                              >
                                参加を承認
                              </Button>
                              <Button
                                type="primary"
                                size="large"
                                style={{
                                  height: "30px",
                                  fontSize: "16px",
                                  minWidth: "120px",
                                  backgroundColor: "#ff4d4f",
                                  borderColor: "#ff4d4f",
                                }}
                                onClick={() => {
                                  // 該当するcreatorEventのIDを取得
                                  const creatorEvent =
                                    event?.creatorEvents?.find(
                                      (ce) => ce.creator.id === creator.id
                                    );
                                  if (creatorEvent) {
                                    mutateResponseCreatorEvent({
                                      creatorEventId: creatorEvent.id,
                                      acceptStatus: AcceptStatus.REJECTED,
                                    });
                                  }
                                }}
                              >
                                参加を拒否
                              </Button>
                            </div>
                          ) : (
                            <div
                              style={{
                                display: "flex",
                                gap: isMobile ? "12px" : "8px",
                                width: isMobile ? "100%" : "auto",
                                justifyContent: isMobile
                                  ? "center"
                                  : "flex-end",
                              }}
                            >
                              <Button
                                shape="circle"
                                color="default"
                                size={isMobile ? "middle" : "small"}
                                icon={
                                  <CheckOutlined style={{ color: "#52c41a" }} />
                                }
                                style={{
                                  borderColor: "#52c41a",
                                }}
                                onMouseEnter={(e) => {
                                  e.currentTarget.style.backgroundColor =
                                    "#52c41a";
                                  const icon =
                                    e.currentTarget.querySelector(".anticon");
                                  if (icon)
                                    (icon as HTMLElement).style.color = "#fff";
                                }}
                                onMouseLeave={(e) => {
                                  e.currentTarget.style.backgroundColor = "";
                                  const icon =
                                    e.currentTarget.querySelector(".anticon");
                                  if (icon)
                                    (icon as HTMLElement).style.color =
                                      "#52c41a";
                                }}
                                onClick={() => {
                                  // 該当するcreatorEventのIDを取得
                                  const creatorEvent =
                                    event?.creatorEvents?.find(
                                      (ce) => ce.creator.id === creator.id
                                    );
                                  if (creatorEvent) {
                                    mutateResponseCreatorEvent({
                                      creatorEventId: creatorEvent.id,
                                      acceptStatus: AcceptStatus.ACCEPTED,
                                    });
                                  }
                                }}
                              />
                              <Button
                                color="danger"
                                shape="circle"
                                size={isMobile ? "middle" : "small"}
                                icon={
                                  <CloseOutlined style={{ color: "#eb2f96" }} />
                                }
                                style={{
                                  borderColor: "#eb2f96",
                                }}
                                onMouseEnter={(e) => {
                                  e.currentTarget.style.backgroundColor =
                                    "#eb2f96";
                                  const icon =
                                    e.currentTarget.querySelector(".anticon");
                                  if (icon)
                                    (icon as HTMLElement).style.color = "#fff";
                                }}
                                onMouseLeave={(e) => {
                                  e.currentTarget.style.backgroundColor = "";
                                  const icon =
                                    e.currentTarget.querySelector(".anticon");
                                  if (icon)
                                    (icon as HTMLElement).style.color =
                                      "#eb2f96";
                                }}
                                onClick={(e) => {
                                  // 該当するcreatorEventのIDを取得
                                  const creatorEvent =
                                    event?.creatorEvents?.find(
                                      (ce) => ce.creator.id === creator.id
                                    );
                                  if (creatorEvent) {
                                    mutateResponseCreatorEvent({
                                      creatorEventId: creatorEvent.id,
                                      acceptStatus: AcceptStatus.REJECTED,
                                    });
                                  }
                                }}
                              />
                            </div>
                          )}
                        </div>
                      </Card>
                    ))}
                </div>
              </Space>
            </div>
          </Card>
        )}
        <Row gutter={[isMobile ? 16 : 24, isMobile ? 16 : 24]}>
          {/* メイン情報 */}
          <Col xs={24} lg={16}>
            <Card>
              {/* イベント画像エリア */}
              <div
                style={{
                  height: isMobile ? "250px" : "400px",
                  backgroundColor: "#f5f5f5",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  borderRadius: "8px",
                  marginBottom: isMobile ? "16px" : "24px",
                }}
              >
                <CalendarOutlined
                  style={{
                    fontSize: isMobile ? "48px" : "64px",
                    color: "#ccc",
                  }}
                />
              </div>

              <div>
                <Title level={isMobile ? 4 : 3}>イベント詳細</Title>
                <Space
                  direction="vertical"
                  size={isMobile ? "small" : "middle"}
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text strong>イベント名:</Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "16px" : "18px",
                        display: isMobile ? "block" : "inline",
                        marginTop: isMobile ? "4px" : "0",
                      }}
                    >
                      {event.title}
                    </Text>
                  </div>

                  {event.description && (
                    <div>
                      <Text strong>説明:</Text>
                      <Paragraph
                        style={{
                          marginTop: "8px",
                          marginBottom: 0,
                          fontSize: isMobile ? "14px" : "inherit",
                        }}
                      >
                        {event.description}
                      </Paragraph>
                    </div>
                  )}

                  <Divider />

                  {/* 開催情報 */}
                  <Row gutter={[isMobile ? 8 : 16, isMobile ? 8 : 16]}>
                    <Col xs={24} sm={12}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <CalendarOutlined
                            style={{
                              fontSize: isMobile ? "20px" : "24px",
                              color: "#1890ff",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>開催日</Text>
                            <div>
                              <Text
                                style={{
                                  fontSize: isMobile ? "14px" : "16px",
                                  fontWeight: "bold",
                                }}
                              >
                                {formatDateOnly(event.startDate)}
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                    <Col xs={24} sm={12}>
                      <Card size="small">
                        <div style={{ textAlign: "center" }}>
                          <ClockCircleOutlined
                            style={{
                              fontSize: isMobile ? "20px" : "24px",
                              color: "#52c41a",
                              marginBottom: "8px",
                            }}
                          />
                          <div>
                            <Text strong>開催時間</Text>
                            <div>
                              <Text
                                style={{
                                  fontSize: isMobile ? "14px" : "16px",
                                  fontWeight: "bold",
                                }}
                              >
                                {formatTimeOnly(event.startDate)} -{" "}
                                {formatTimeOnly(event.endDate)}
                              </Text>
                            </div>
                          </div>
                        </div>
                      </Card>
                    </Col>
                  </Row>

                  <Divider />

                  {/* 会場情報 */}
                  <div>
                    <Title level={isMobile ? 5 : 4}>会場情報</Title>
                    <Card size="small" style={{ marginTop: "12px" }}>
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          flexDirection: isMobile ? "column" : "row",
                          textAlign: isMobile ? "center" : "left",
                          gap: isMobile ? "12px" : "0",
                        }}
                      >
                        {event.venue.imageUrl ? (
                          <Avatar
                            size={isMobile ? 50 : 60}
                            src={event.venue.imageUrl}
                          />
                        ) : (
                          <Avatar
                            size={isMobile ? 50 : 60}
                            icon={<EnvironmentOutlined />}
                          />
                        )}
                        <div
                          style={{
                            marginLeft: isMobile ? "0" : "16px",
                            flex: 1,
                          }}
                        >
                          <Title
                            level={5}
                            style={{
                              margin: 0,
                              fontSize: isMobile ? "14px" : "16px",
                            }}
                          >
                            {event.venue.name}
                          </Title>
                          <Text
                            type="secondary"
                            style={{ fontSize: isMobile ? "12px" : "14px" }}
                          >
                            {event.venue.address}
                          </Text>
                          {event.venue.capacity && (
                            <div style={{ marginTop: "4px" }}>
                              <Text
                                type="secondary"
                                style={{ fontSize: isMobile ? "12px" : "14px" }}
                              >
                                定員: {event.venue.capacity}人
                              </Text>
                            </div>
                          )}
                        </div>
                        <Button
                          type="link"
                          size={isMobile ? "small" : "middle"}
                          onClick={() =>
                            router.push(`/venues/${event.venue.id}`)
                          }
                          style={{
                            marginTop: isMobile ? "8px" : "0",
                            fontSize: isMobile ? "12px" : "14px",
                          }}
                        >
                          会場詳細を見る
                        </Button>
                      </div>
                    </Card>
                  </div>

                  <Divider />

                  {/* 参加クリエイター */}
                  <div>
                    <Title level={isMobile ? 5 : 4}>参加クリエイター</Title>
                    {event.creatorEvents.filter(
                      (creatorEvent) =>
                        creatorEvent.acceptStatus === AcceptStatus.ACCEPTED
                    ).length > 0 ? (
                      <Row
                        gutter={[isMobile ? 8 : 16, isMobile ? 8 : 16]}
                        style={{ marginTop: "12px" }}
                      >
                        {event.creatorEvents
                          .filter(
                            (creatorEvent) =>
                              creatorEvent.acceptStatus ===
                              AcceptStatus.ACCEPTED
                          )
                          .map((creatorEvent) => (
                            <Col xs={24} sm={12} md={8} key={creatorEvent.id}>
                              <Card size="small" hoverable>
                                <div style={{ textAlign: "center" }}>
                                  {creatorEvent.creator.imageUrl ? (
                                    <Avatar
                                      size={isMobile ? 50 : 60}
                                      src={creatorEvent.creator.imageUrl}
                                      icon={<UserOutlined />}
                                    />
                                  ) : (
                                    <Avatar
                                      size={isMobile ? 50 : 60}
                                      icon={<UserOutlined />}
                                      style={{
                                        backgroundColor: "#f0f0f0",
                                        color: "#999",
                                      }}
                                    />
                                  )}
                                  <div style={{ marginTop: "8px" }}>
                                    <Text
                                      strong
                                      style={{
                                        fontSize: isMobile ? "14px" : "16px",
                                      }}
                                    >
                                      {creatorEvent.creator.name}
                                    </Text>
                                    {creatorEvent.creator.description && (
                                      <div style={{ marginTop: "4px" }}>
                                        <Text
                                          type="secondary"
                                          style={{
                                            fontSize: isMobile
                                              ? "11px"
                                              : "12px",
                                          }}
                                        >
                                          {creatorEvent.creator.description
                                            .length > (isMobile ? 30 : 50)
                                            ? `${creatorEvent.creator.description.substring(
                                                0,
                                                isMobile ? 30 : 50
                                              )}...`
                                            : creatorEvent.creator.description}
                                        </Text>
                                      </div>
                                    )}
                                  </div>
                                  <Button
                                    type="link"
                                    size="small"
                                    onClick={() =>
                                      router.push(
                                        `/creators/${creatorEvent.creator.id}`
                                      )
                                    }
                                    style={{
                                      fontSize: isMobile ? "12px" : "14px",
                                    }}
                                  >
                                    詳細を見る
                                  </Button>
                                </div>
                              </Card>
                            </Col>
                          ))}
                      </Row>
                    ) : (
                      <div
                        style={{
                          textAlign: "center",
                          padding: isMobile ? "16px" : "24px",
                          backgroundColor: "#f5f5f5",
                          borderRadius: "8px",
                          marginTop: "12px",
                        }}
                      >
                        <TeamOutlined
                          style={{
                            fontSize: isMobile ? "24px" : "32px",
                            color: "#ccc",
                          }}
                        />
                        <div style={{ marginTop: "8px" }}>
                          <Text
                            type="secondary"
                            style={{ fontSize: isMobile ? "12px" : "14px" }}
                          >
                            参加クリエイターはまだいません
                          </Text>
                        </div>
                      </div>
                    )}
                  </div>
                </Space>
              </div>
            </Card>
          </Col>

          {/* サイドバー情報 */}
          <Col xs={24} lg={8}>
            <Space
              direction="vertical"
              size={isMobile ? "small" : "middle"}
              style={{ width: "100%" }}
            >
              {/* 基本情報カード */}
              <Card title="イベント情報" size="small">
                <Space
                  direction="vertical"
                  size="small"
                  style={{ width: "100%" }}
                >
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      イベントID:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {event.id}
                    </Text>
                  </div>
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      開始日時:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {formatDate(event.startDate)}
                    </Text>
                  </div>
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      終了日時:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {formatDate(event.endDate)}
                    </Text>
                  </div>
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      会場:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {event.venue.name}
                    </Text>
                  </div>
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      参加クリエイター数:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {event.creatorEvents.length}人
                    </Text>
                  </div>
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      登録日:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {new Date(event.createdAt).toLocaleDateString("ja-JP")}
                    </Text>
                  </div>
                  <div>
                    <Text
                      type="secondary"
                      style={{ fontSize: isMobile ? "12px" : "14px" }}
                    >
                      最終更新:
                    </Text>
                    <Text
                      style={{
                        marginLeft: "8px",
                        fontSize: isMobile ? "12px" : "14px",
                      }}
                    >
                      {new Date(event.updatedAt).toLocaleDateString("ja-JP")}
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
                  <Button
                    type="primary"
                    block
                    icon={<CalendarOutlined />}
                    style={{
                      backgroundColor: anBlue,
                      borderColor: anBlue,
                      height: isMobile ? "40px" : "32px",
                      fontSize: isMobile ? "14px" : "14px",
                    }}
                  >
                    参加申し込み
                  </Button>
                  <Button
                    block
                    type="primary"
                    icon={<EnvironmentOutlined />}
                    style={{
                      backgroundColor: anBlue,
                      borderColor: anBlue,
                      height: isMobile ? "40px" : "32px",
                      fontSize: isMobile ? "14px" : "14px",
                    }}
                  >
                    会場詳細を見る
                  </Button>
                  <Button
                    block
                    icon={<TeamOutlined />}
                    style={{
                      height: isMobile ? "40px" : "32px",
                      fontSize: isMobile ? "14px" : "14px",
                    }}
                  >
                    クリエイター一覧
                  </Button>
                </Space>
              </Card>

              {/* イベントステータス */}
              <Card title="イベントステータス" size="small">
                <div style={{ textAlign: "center" }}>
                  {scheduleStatus === "future" ? (
                    <div>
                      <Tag
                        color="green"
                        style={{
                          fontSize: isMobile ? "12px" : "14px",
                          padding: isMobile ? "2px 8px" : "4px 12px",
                        }}
                      >
                        開催予定
                      </Tag>
                      <div style={{ marginTop: "8px" }}>
                        <Text
                          type="secondary"
                          style={{ fontSize: isMobile ? "12px" : "14px" }}
                        >
                          このイベントは開催予定です
                        </Text>
                      </div>
                    </div>
                  ) : scheduleStatus === "past" ? (
                    <div>
                      <Tag
                        color="red"
                        style={{
                          fontSize: isMobile ? "12px" : "14px",
                          padding: isMobile ? "2px 8px" : "4px 12px",
                        }}
                      >
                        開催済み
                      </Tag>
                      <div style={{ marginTop: "8px" }}>
                        <Text
                          type="secondary"
                          style={{ fontSize: isMobile ? "12px" : "14px" }}
                        >
                          このイベントは終了しました
                        </Text>
                      </div>
                    </div>
                  ) : (
                    <div>
                      <Tag
                        color="orange"
                        style={{
                          fontSize: isMobile ? "12px" : "14px",
                          padding: isMobile ? "2px 8px" : "4px 12px",
                        }}
                      >
                        開催中
                      </Tag>
                      <div style={{ marginTop: "8px" }}>
                        <Text
                          type="secondary"
                          style={{ fontSize: isMobile ? "12px" : "14px" }}
                        >
                          このイベントは開催中です
                        </Text>
                      </div>
                    </div>
                  )}
                </div>
              </Card>
            </Space>
          </Col>
        </Row>
      </div>

      <EventModal
        visible={modalVisibleMode !== undefined}
        startStep={modalVisibleMode}
        event={event}
        onCancel={() => {
          setModalVisibleMode(undefined);
        }}
        onSuccess={() => {
          refetch();
          setModalVisibleMode(undefined);
        }}
      />
    </PageLayout>
  );
};

export default EventDetailPage;
